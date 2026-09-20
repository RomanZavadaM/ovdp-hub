import { Tabs } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
export default function Layout() {
  return <><StatusBar style="dark" /><Tabs screenOptions={{ headerShown: false, tabBarActiveTintColor: '#165d45' }}><Tabs.Screen name="index" options={{ title: 'Каталог', tabBarLabel: 'Каталог' }} /><Tabs.Screen name="calendar" options={{ title: 'Аукціони', tabBarLabel: 'Аукціони' }} /><Tabs.Screen name="calculator" options={{ title: 'Калькулятор', tabBarLabel: 'Калькулятор' }} /></Tabs></>;
}
