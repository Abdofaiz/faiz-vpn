// Server Monitoring Utility

import { api } from './api';

class ServerMonitor {
  constructor() {
    this.serverInfo = new Map();
    this.certInfo = new Map();
    this.lastCheck = 0;
    this.checkInterval = 300000; // 5 minutes
  }

  async checkServerBanner(port) {
    try {
      const result = await api.request('/monitor/banner', 'POST', { port });
      return {
        port,
        banner: result.banner,
        timestamp: Date.now()
      };
    } catch (error) {
      console.error(`Banner check failed for port ${port}:`, error);
      return {
        port,
        error: error.message,
        timestamp: Date.now()
      };
    }
  }

  async checkServerResponse() {
    const services = [
      { name: 'SSH', port: 22 },
      { name: 'XRAY', port: 443 },
      { name: 'HTTP', port: 80 },
      { name: 'WebSocket', port: 8080 }
    ];

    const results = await Promise.all(services.map(async (service) => {
      try {
        const response = await api.request('/monitor/service', 'POST', service);
        return {
          ...service,
          status: response.status,
          responseTime: response.responseTime,
          timestamp: Date.now()
        };
      } catch (error) {
        return {
          ...service,
          status: 'error',
          error: error.message,
          timestamp: Date.now()
        };
      }
    }));

    this.serverInfo.set('services', results);
    return results;
  }

  async checkCertificates() {
    try {
      const certs = await api.request('/monitor/certificates', 'GET');
      const results = certs.map(cert => ({
        domain: cert.domain,
        issuer: cert.issuer,
        validFrom: new Date(cert.validFrom),
        validTo: new Date(cert.validTo),
        daysRemaining: Math.floor((new Date(cert.validTo) - new Date()) / (1000 * 60 * 60 * 24)),
        status: this.getCertStatus(cert.validTo)
      }));

      this.certInfo.set('certificates', results);
      return results;
    } catch (error) {
      console.error('Certificate check failed:', error);
      throw error;
    }
  }

  getCertStatus(validTo) {
    const daysRemaining = Math.floor((new Date(validTo) - new Date()) / (1000 * 60 * 60 * 24));
    if (daysRemaining < 0) return 'expired';
    if (daysRemaining < 7) return 'critical';
    if (daysRemaining < 30) return 'warning';
    return 'valid';
  }

  async checkAll() {
    if (Date.now() - this.lastCheck < this.checkInterval) {
      return {
        services: this.serverInfo.get('services'),
        certificates: this.certInfo.get('certificates')
      };
    }

    try {
      const [services, certificates] = await Promise.all([
        this.checkServerResponse(),
        this.checkCertificates()
      ]);

      this.lastCheck = Date.now();
      return { services, certificates };
    } catch (error) {
      console.error('Server check failed:', error);
      throw error;
    }
  }

  getServiceStatus(serviceName) {
    const services = this.serverInfo.get('services') || [];
    return services.find(s => s.name === serviceName);
  }

  getCertificateInfo(domain) {
    const certs = this.certInfo.get('certificates') || [];
    return certs.find(c => c.domain === domain);
  }

  async renewCertificate(domain) {
    try {
      const result = await api.request('/monitor/renew-cert', 'POST', { domain });
      await this.checkCertificates(); // Refresh cert info
      return result;
    } catch (error) {
      console.error('Certificate renewal failed:', error);
      throw error;
    }
  }

  getExpiringCertificates(days = 30) {
    const certs = this.certInfo.get('certificates') || [];
    return certs.filter(cert => cert.daysRemaining <= days);
  }

  getServiceUptime() {
    const services = this.serverInfo.get('services') || [];
    return services.reduce((uptime, service) => {
      uptime[service.name] = service.status === 'running' ? 'up' : 'down';
      return uptime;
    }, {});
  }
}

export const serverMonitor = new ServerMonitor(); 