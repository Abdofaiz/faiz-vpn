import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Card, Title, Paragraph, Button, Portal, Dialog } from 'react-native-paper';
import { api } from '../utils/api';

export default function UserDetailScreen({ route, navigation }) {
  const { user } = route.params;
  const [details, setDetails] = useState(null);
  const [loading, setLoading] = useState(false);
  const [showConfig, setShowConfig] = useState(false);

  const fetchDetails = async () => {
    try {
      const data = await api.getUserStatus(user.username);
      setDetails(data);
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    fetchDetails();
    const interval = setInterval(fetchDetails, 10000);
    return () => clearInterval(interval);
  }, []);

  const handleDelete = () => {
    Alert.alert(
      'Delete User',
      `Are you sure you want to delete ${user.username}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: async () => {
            try {
              setLoading(true);
              await api.deleteUser(user.username);
              navigation.goBack();
            } catch (error) {
              Alert.alert('Error', error.message);
            } finally {
              setLoading(false);
            }
          }
        }
      ]
    );
  };

  const handleLock = async () => {
    try {
      setLoading(true);
      if (details.status === 'locked') {
        await api.unlockUser(user.username);
      } else {
        await api.lockUser(user.username);
      }
      await fetchDetails();
    } catch (error) {
      Alert.alert('Error', error.message);
    } finally {
      setLoading(false);
    }
  };

  if (!details) return null;

  return (
    <ScrollView style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <Title>{user.username}</Title>
          <Paragraph>Type: {user.type}</Paragraph>
          <Paragraph>Status: {details.status}</Paragraph>
          <Paragraph>Expires: {details.expiry}</Paragraph>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Usage Statistics</Title>
          <Paragraph>Quota Used: {details.quota_used} GB</Paragraph>
          <Paragraph>Quota Limit: {details.quota_limit} GB</Paragraph>
          <Paragraph>Active Connections: {details.current_logins}</Paragraph>
        </Card.Content>
      </Card>

      <View style={styles.buttonContainer}>
        <Button 
          mode="contained"
          onPress={() => setShowConfig(true)}
          style={styles.button}
        >
          Show Config
        </Button>

        <Button 
          mode="contained"
          onPress={handleLock}
          loading={loading}
          style={styles.button}
        >
          {details.status === 'locked' ? 'Unlock' : 'Lock'} User
        </Button>

        <Button 
          mode="contained"
          onPress={handleDelete}
          loading={loading}
          style={[styles.button, styles.deleteButton]}
        >
          Delete User
        </Button>
      </View>

      <Portal>
        <Dialog visible={showConfig} onDismiss={() => setShowConfig(false)}>
          <Dialog.Title>Configuration</Dialog.Title>
          <Dialog.Content>
            <Paragraph>Host: {details.config.host}</Paragraph>
            <Paragraph>Port: {details.config.port}</Paragraph>
            <Paragraph>Username: {user.username}</Paragraph>
            {user.type === 'xray' && (
              <Paragraph>UUID: {details.config.uuid}</Paragraph>
            )}
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setShowConfig(false)}>Close</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
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
  },
  buttonContainer: {
    gap: 12
  },
  button: {
    marginBottom: 8
  },
  deleteButton: {
    backgroundColor: '#dc3545'
  }
}); 