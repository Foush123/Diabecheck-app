import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.person), title: Text('Ahmed'), subtitle: Text('ahmed@example.com')),
          Divider(),
          ListTile(leading: Icon(Icons.monitor_heart_outlined), title: Text('Sugar logs')),
          ListTile(leading: Icon(Icons.local_drink_outlined), title: Text('Water intake')),
          ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }
}


