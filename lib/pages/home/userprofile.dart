import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.white10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              User? user = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user?.photoURL ?? ''),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Name: ${user?.displayName ?? "Not Available"}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${user?.email ?? "Not Available"}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Log out the user
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context); // Go back after logging out
                    },
                    child: Text('Log out'),
                  ),
                ],
              );
            } else {
              return Center(child: Text('No user signed in.'));
            }
          },
        ),
      ),
    );
  }
}
