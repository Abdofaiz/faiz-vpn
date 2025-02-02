import React, { useState } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { TextInput, Button, SegmentedButtons, HelperText } from 'react-native-paper';
import { api } from '../utils/api';

export default function AddUserScreen({ navigation }) {
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({
    type: 'ssh',
    username: '',
    password: '',
    duration: '30',
    quota: '10'
  });
  const [error, setError] = useState(null);

  const handleSubmit = async () => {
    try {
      setLoading(true);
      setError(null);
      await api.createUser(form);
      navigation.goBack();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <SegmentedButtons
        value={form.type}
        onValueChange={value => setForm({...form, type: value})}
        buttons={[
          { value: 'ssh', label: 'SSH' },
          { value: 'xray', label: 'XRAY' },
          { value: 'trojan', label: 'Trojan' }
        ]}
        style={styles.segment}
      />

      <TextInput
        label="Username"
        value={form.username}
        onChangeText={text => setForm({...form, username: text})}
        style={styles.input}
      />

      <TextInput
        label="Password"
        value={form.password}
        onChangeText={text => setForm({...form, password: text})}
        secureTextEntry
        style={styles.input}
      />

      <TextInput
        label="Duration (days)"
        value={form.duration}
        onChangeText={text => setForm({...form, duration: text})}
        keyboardType="numeric"
        style={styles.input}
      />

      <TextInput
        label="Quota (GB)"
        value={form.quota}
        onChangeText={text => setForm({...form, quota: text})}
        keyboardType="numeric"
        style={styles.input}
      />

      {error && <HelperText type="error">{error}</HelperText>}

      <Button 
        mode="contained" 
        onPress={handleSubmit}
        loading={loading}
        style={styles.button}
      >
        Create User
      </Button>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5'
  },
  segment: {
    marginBottom: 16
  },
  input: {
    marginBottom: 12,
    backgroundColor: '#fff'
  },
  button: {
    marginTop: 16
  }
}); 