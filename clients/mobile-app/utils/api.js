// API Client Utility

import AsyncStorage from '@react-native-async-storage/async-storage';

class ApiClient {
  constructor() {
    this.baseUrl = null;
    this.apiKey = null;
    this.init();
  }

  async init() {
    this.baseUrl = await AsyncStorage.getItem('apiUrl');
    this.apiKey = await AsyncStorage.getItem('apiKey');
  }

  async request(endpoint, method = 'GET', data = null) {
    if (!this.baseUrl || !this.apiKey) {
      throw new Error('API not configured');
    }

    const options = {
      method,
      headers: {
        'X-API-Key': this.apiKey,
        'Content-Type': 'application/json'
      }
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    try {
      const response = await fetch(`${this.baseUrl}${endpoint}`, options);
      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.message || 'API request failed');
      }

      return result;
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }

  // User Management
  async createUser(data) {
    return this.request('/user/add', 'POST', data);
  }

  async deleteUser(username) {
    return this.request(`/user/delete/${username}`, 'DELETE');
  }

  async getUserStatus(username) {
    return this.request(`/user/status/${username}`);
  }

  async lockUser(username) {
    return this.request(`/user/lock/${username}`, 'POST');
  }

  async unlockUser(username) {
    return this.request(`/user/unlock/${username}`, 'POST');
  }

  // Server Management
  async getServerStatus() {
    return this.request('/server/status');
  }

  async changeDomain(data) {
    return this.request('/server/domain', 'POST', data);
  }

  async updatePorts(data) {
    return this.request('/server/ports', 'POST', data);
  }

  // Monitoring
  async getMonitorResources() {
    return this.request('/monitor/resources');
  }

  async getMonitorBandwidth() {
    return this.request('/monitor/bandwidth');
  }

  async getMonitorLogins() {
    return this.request('/monitor/logins');
  }

  // Backup & Security
  async createBackup() {
    return this.request('/backup/create', 'POST');
  }

  async restoreBackup(file) {
    const formData = new FormData();
    formData.append('file', file);
    return this.request('/backup/restore', 'POST', formData);
  }

  async updateApiKey(data) {
    const result = await this.request('/settings/api-key', 'POST', data);
    if (result.success) {
      await AsyncStorage.setItem('apiKey', data.apiKey);
      this.apiKey = data.apiKey;
    }
    return result;
  }
}

export const api = new ApiClient(); 