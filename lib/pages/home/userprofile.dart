import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: Text('No user signed in.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Name: ${user.displayName ?? "Not Available"}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${user.email ?? "Not Available"}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
      ),
    );
  }
}
