import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { Card, Title, Paragraph } from 'react-native-paper';
import { LineChart } from 'react-native-chart-kit';
import { api } from '../utils/api';

export default function DashboardScreen() {
  const [resources, setResources] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchData = async () => {
    try {
      const data = await api.getMonitorResources();
      setResources(data);
    } catch (error) {
      console.error(error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchData();
    setRefreshing(false);
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  if (!resources) return null;

  return (
    <ScrollView 
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <Card style={styles.card}>
        <Card.Content>
          <Title>System Resources</Title>
          <LineChart
            data={{
              labels: ['CPU', 'Memory', 'Disk'],
              datasets: [{
                data: [
                  resources.cpu.usage,
                  resources.memory.percentage,
                  resources.disk.percentage
                ]
              }]
            }}
            width={300}
            height={200}
            chartConfig={{
              backgroundColor: '#ffffff',
              backgroundGradientFrom: '#ffffff',
              backgroundGradientTo: '#ffffff',
              color: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`
            }}
          />
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Memory Usage</Title>
          <Paragraph>
            Used: {resources.memory.used}MB / {resources.memory.total}MB
          </Paragraph>
          <Paragraph>
            Free: {resources.memory.free}MB
          </Paragraph>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Disk Usage</Title>
          <Paragraph>
            Used: {resources.disk.used} / {resources.disk.total}
          </Paragraph>
          <Paragraph>
            Free: {resources.disk.free}
          </Paragraph>
        </Card.Content>
      </Card>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5'
  },
  card: {
    marginBottom: 16
  }
}); 