import React, { useState, useEffect } from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { Card, Title, Paragraph, Button, FAB } from 'react-native-paper';
import { api } from '../utils/api';

export default function UsersScreen({ navigation }) {
  const [users, setUsers] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const fetchUsers = async () => {
    try {
      const bandwidth = await api.getMonitorBandwidth();
      const userList = Object.entries(bandwidth).map(([username, data]) => ({
        username,
        ...data
      }));
      setUsers(userList);
    } catch (error) {
      console.error(error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchUsers();
    setRefreshing(false);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const renderUser = ({ item }) => (
    <Card style={styles.card} onPress={() => navigation.navigate('UserDetail', { user: item })}>
      <Card.Content>
        <Title>{item.username}</Title>
        <Paragraph>Type: {item.type || '-'}</Paragraph>
        <Paragraph>Status: {item.status || 'Active'}</Paragraph>
        <Paragraph>Quota: {item.quota_used}/{item.quota_limit} GB</Paragraph>
      </Card.Content>
      <Card.Actions>
        <Button onPress={() => navigation.navigate('UserDetail', { user: item })}>
          Details
        </Button>
      </Card.Actions>
    </Card>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={users}
        renderItem={renderUser}
        keyExtractor={item => item.username}
        refreshing={refreshing}
        onRefresh={onRefresh}
      />
      <FAB
        style={styles.fab}
        icon="plus"
        onPress={() => navigation.navigate('AddUser')}
      />
    </View>
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
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0
  }
}); 