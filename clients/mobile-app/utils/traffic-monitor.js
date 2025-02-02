// Traffic Monitoring Utility

class TrafficMonitor {
  constructor() {
    this.trafficData = new Map();
    this.alerts = [];
    this.thresholds = {
      bandwidth: 1000, // MB per hour
      connections: 10, // per user
      scanAttempts: 5  // per minute
    };
  }

  addTrafficSample(data) {
    const { username, bytes, timestamp } = data;
    if (!this.trafficData.has(username)) {
      this.trafficData.set(username, []);
    }
    
    const samples = this.trafficData.get(username);
    samples.push({ bytes, timestamp });

    // Keep only last hour of samples
    const hourAgo = Date.now() - 3600000;
    while (samples.length && samples[0].timestamp < hourAgo) {
      samples.shift();
    }

    this.checkThresholds(username);
  }

  checkThresholds(username) {
    const samples = this.trafficData.get(username);
    if (!samples?.length) return;

    // Calculate total bandwidth usage
    const totalBytes = samples.reduce((sum, sample) => sum + sample.bytes, 0);
    const mbPerHour = totalBytes / (1024 * 1024);

    if (mbPerHour > this.thresholds.bandwidth) {
      this.addAlert({
        type: 'bandwidth_exceeded',
        username,
        value: mbPerHour,
        threshold: this.thresholds.bandwidth,
        timestamp: Date.now()
      });
    }
  }

  addAlert(alert) {
    this.alerts.unshift(alert);
    // Keep last 100 alerts
    if (this.alerts.length > 100) {
      this.alerts.pop();
    }
  }

  getRecentAlerts(count = 10) {
    return this.alerts.slice(0, count);
  }

  getUserTraffic(username, period = 'hour') {
    const samples = this.trafficData.get(username) || [];
    let startTime;

    switch (period) {
      case 'hour':
        startTime = Date.now() - 3600000;
        break;
      case 'day':
        startTime = Date.now() - 86400000;
        break;
      case 'week':
        startTime = Date.now() - 604800000;
        break;
      default:
        startTime = 0;
    }

    return samples
      .filter(sample => sample.timestamp >= startTime)
      .reduce((sum, sample) => sum + sample.bytes, 0);
  }

  setThreshold(type, value) {
    if (type in this.thresholds) {
      this.thresholds[type] = value;
    }
  }

  clearData(username) {
    if (username) {
      this.trafficData.delete(username);
    } else {
      this.trafficData.clear();
    }
  }
}

export const trafficMonitor = new TrafficMonitor(); 