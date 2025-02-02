// VPS API Client

class VPSApi {
    constructor(baseUrl, apiKey) {
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
    }

    async request(endpoint, method = 'GET', data = null) {
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

        const response = await fetch(`${this.baseUrl}${endpoint}`, options);
        return response.json();
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

    async getMonitorResources() {
        return this.request('/monitor/resources');
    }

    async getMonitorBandwidth() {
        return this.request('/monitor/bandwidth');
    }

    async getMonitorLogins() {
        return this.request('/monitor/logins');
    }
} 