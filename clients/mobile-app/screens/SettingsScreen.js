import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { List, Switch, Button, Portal, Dialog, TextInput } from 'react-native-paper';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { api } from '../utils/api';

export default function SettingsScreen() {
  const [loading, setLoading] = useState(false);
  const [showApiKey, setShowApiKey] = useState(false);
  const [showDomain, setShowDomain] = useState(false);
  const [settings, setSettings] = useState({
    notifications: true,
    darkMode: false,
    autoBackup: true,
    blockScanner: true,
    blockTorrent: true
  });

  const [domain, setDomain] = useState('');
  const [apiKey, setApiKey] = useState('');

  const handleBackup = async () => {
    try {
      setLoading(true);
      const backup = await api.createBackup();
      await AsyncStorage.setItem('lastBackup', new Date().toISOString());
      Alert.alert('Success', 'Backup created successfully');
    } catch (error) {
      Alert.alert('Error', error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDomainChange = async () => {
    try {
      setLoading(true);
      await api.changeDomain({ domain });
      setShowDomain(false);
      Alert.alert('Success', 'Domain updated successfully');
    } catch (error) {
      Alert.alert('Error', error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleApiKeyChange = async () => {
    try {
      setLoading(true);
      await api.updateApiKey({ apiKey });
      setShowApiKey(false);
      Alert.alert('Success', 'API key updated successfully');
    } catch (error) {
      Alert.alert('Error', error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <List.Section>
        <List.Subheader>Server Settings</List.Subheader>
        <List.Item
          title="Change Domain"
          description="Update server domain/host"
          right={() => <List.Icon icon="web" />}
          onPress={() => setShowDomain(true)}
        />
        <List.Item
          title="API Key"
          description="Manage API authentication"
          right={() => <List.Icon icon="key" />}
          onPress={() => setShowApiKey(true)}
        />
        <List.Item
          title="Backup Data"
          description="Create server backup"
          right={() => <List.Icon icon="backup-restore" />}
          onPress={handleBackup}
        />
      </List.Section>

      <List.Section>
        <List.Subheader>Security</List.Subheader>
        <List.Item
          title="Block Scanner"
          description="Block port scanning attempts"
          right={() => (
            <Switch
              value={settings.blockScanner}
              onValueChange={value => 
                setSettings({...settings, blockScanner: value})
              }
            />
          )}
        />
        <List.Item
          title="Block Torrent"
          description="Block torrent traffic"
          right={() => (
            <Switch
              value={settings.blockTorrent}
              onValueChange={value => 
                setSettings({...settings, blockTorrent: value})
              }
            />
          )}
        />
      </List.Section>

      <List.Section>
        <List.Subheader>App Settings</List.Subheader>
        <List.Item
          title="Notifications"
          description="Enable push notifications"
          right={() => (
            <Switch
              value={settings.notifications}
              onValueChange={value => 
                setSettings({...settings, notifications: value})
              }
            />
          )}
        />
        <List.Item
          title="Dark Mode"
          description="Toggle dark theme"
          right={() => (
            <Switch
              value={settings.darkMode}
              onValueChange={value => 
                setSettings({...settings, darkMode: value})
              }
            />
          )}
        />
        <List.Item
          title="Auto Backup"
          description="Daily automatic backup"
          right={() => (
            <Switch
              value={settings.autoBackup}
              onValueChange={value => 
                setSettings({...settings, autoBackup: value})
              }
            />
          )}
        />
      </List.Section>

      <Portal>
        <Dialog visible={showDomain} onDismiss={() => setShowDomain(false)}>
          <Dialog.Title>Change Domain</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="Domain"
              value={domain}
              onChangeText={setDomain}
              autoCapitalize="none"
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setShowDomain(false)}>Cancel</Button>
            <Button onPress={handleDomainChange} loading={loading}>Save</Button>
          </Dialog.Actions>
        </Dialog>

        <Dialog visible={showApiKey} onDismiss={() => setShowApiKey(false)}>
          <Dialog.Title>Update API Key</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="API Key"
              value={apiKey}
              onChangeText={setApiKey}
              autoCapitalize="none"
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setShowApiKey(false)}>Cancel</Button>
            <Button onPress={handleApiKeyChange} loading={loading}>Save</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5'
  }
}); 