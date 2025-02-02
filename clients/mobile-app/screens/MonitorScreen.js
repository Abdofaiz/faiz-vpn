import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { Card, Title, Paragraph, Badge, List, Button } from 'react-native-paper';
import { serverMonitor } from '../utils/server-monitor';

export default function MonitorScreen() {
  const [loading, setLoading] = useState(true);
  const [serverData, setServerData] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchData = async () => {
    try {
      const data = await serverMonitor.checkAll();
      setServerData(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchData();
    setRefreshing(false);
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 300000); // 5 minutes
    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (status) => {
    switch (status) {
      case 'running':
      case 'valid':
        return 'green';
      case 'warning':
        return 'orange';
      case 'critical':
      case 'error':
      case 'expired':
        return 'red';
      default:
        return 'gray';
    }
  };

  if (!serverData) return null;

  return (
    <ScrollView 
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <Card style={styles.card}>
        <Card.Content>
          <Title>Service Status</Title>
          {serverData.services.map((service) => (
            <List.Item
              key={service.name}
              title={service.name}
              description={`Port: ${service.port}`}
              right={() => (
                <Badge
                  style={[
                    styles.badge,
                    { backgroundColor: getStatusColor(service.status) }
                  ]}
                >
                  {service.status}
                </Badge>
              )}
            />
          ))}
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>SSL Certificates</Title>
          {serverData.certificates.map((cert) => (
            <List.Item
              key={cert.domain}
              title={cert.domain}
              description={`Expires in ${cert.daysRemaining} days`}
              right={() => (
                <Badge
                  style={[
                    styles.badge,
                    { backgroundColor: getStatusColor(cert.status) }
                  ]}
                >
                  {cert.status}
                </Badge>
              )}
              onPress={() => {
                if (cert.status !== 'valid') {
                  serverMonitor.renewCertificate(cert.domain);
                }
              }}
            />
          ))}
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Server Response Times</Title>
          {serverData.services.map((service) => (
            <List.Item
              key={service.name}
              title={service.name}
              description={
                service.responseTime 
                  ? `${service.responseTime}ms`
                  : 'No response'
              }
            />
          ))}
        </Card.Content>
      </Card>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5'
  },
  card: {
    margin: 8
  },
  badge: {
    alignSelf: 'center'
  }
}); 