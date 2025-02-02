// WebSocket Client for Real-time Updates

import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';
import * as Notifications from 'expo-notifications';

class WSClient {
  constructor() {
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.listeners = new Map();
    this.setupNotifications();
  }

  async setupNotifications() {
    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync('default', {
        name: 'default',
        importance: Notifications.AndroidImportance.MAX,
        vibrationPattern: [0, 250, 250, 250],
      });
    }

    Notifications.setNotificationHandler({
      handleNotification: async () => ({
        shouldShowAlert: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
      }),
    });
  }

  async connect() {
    try {
      const baseUrl = await AsyncStorage.getItem('apiUrl');
      const apiKey = await AsyncStorage.getItem('apiKey');
      const wsUrl = baseUrl.replace('http', 'ws') + '/ws';

      this.ws = new WebSocket(wsUrl, {
        headers: { 'X-API-Key': apiKey }
      });

      this.ws.onopen = this.handleOpen.bind(this);
      this.ws.onmessage = this.handleMessage.bind(this);
      this.ws.onerror = this.handleError.bind(this);
      this.ws.onclose = this.handleClose.bind(this);
    } catch (error) {
      console.error('WebSocket connection error:', error);
    }
  }

  handleOpen() {
    console.log('WebSocket connected');
    this.reconnectAttempts = 0;
  }

  async handleMessage(event) {
    try {
      const data = JSON.parse(event.data);
      
      // Handle different message types
      switch (data.type) {
        case 'user_login':
          await this.handleUserLogin(data);
          break;
        case 'quota_exceeded':
          await this.handleQuotaExceeded(data);
          break;
        case 'system_alert':
          await this.handleSystemAlert(data);
          break;
        case 'traffic_spike':
          await this.handleTrafficSpike(data);
          break;
      }

      // Notify listeners
      if (this.listeners.has(data.type)) {
        this.listeners.get(data.type).forEach(callback => callback(data));
      }
    } catch (error) {
      console.error('WebSocket message error:', error);
    }
  }

  async handleUserLogin(data) {
    await this.showNotification(
      'New Login',
      `User ${data.username} logged in from ${data.ip}`
    );
  }

  async handleQuotaExceeded(data) {
    await this.showNotification(
      'Quota Exceeded',
      `User ${data.username} has exceeded their quota limit`
    );
  }

  async handleSystemAlert(data) {
    await this.showNotification(
      'System Alert',
      data.message
    );
  }

  async handleTrafficSpike(data) {
    await this.showNotification(
      'Traffic Alert',
      `Unusual traffic detected from ${data.source}`
    );
  }

  async showNotification(title, body) {
    const enabled = await AsyncStorage.getItem('notifications') === 'true';
    if (!enabled) return;

    await Notifications.scheduleNotificationAsync({
      content: {
        title,
        body,
        data: { timestamp: new Date().toISOString() },
      },
      trigger: null,
    });
  }

  handleError(error) {
    console.error('WebSocket error:', error);
  }

  handleClose() {
    console.log('WebSocket closed');
    this.attemptReconnect();
  }

  attemptReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        console.log(`Attempting reconnect ${this.reconnectAttempts}/${this.maxReconnectAttempts}`);
        this.connect();
      }, 5000 * this.reconnectAttempts);
    }
  }

  addListener(type, callback) {
    if (!this.listeners.has(type)) {
      this.listeners.set(type, new Set());
    }
    this.listeners.get(type).add(callback);
  }

  removeListener(type, callback) {
    if (this.listeners.has(type)) {
      this.listeners.get(type).delete(callback);
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

export const wsClient = new WSClient(); 