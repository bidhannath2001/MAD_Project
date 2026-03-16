import 'package:classcentral/pages/home/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';

class DrawerSlider extends StatelessWidget {
  const DrawerSlider({super.key});

  Widget listTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 32,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.user;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white54,
                      radius: 34,
                      child: CircleAvatar(
                        backgroundColor: Colors.yellow,
                        radius: 31,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? const Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome ${user?.displayName ?? "Guest"}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 32,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          context.read<AuthProvider>().signOut();
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          listTile(
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          listTile(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
          listTile(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {},
          ),
          listTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}