import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/auth/login.dart';
import 'package:food_app/pages/home/userprofile.dart';

class DrawerSlider extends StatelessWidget {
  const DrawerSlider({super.key});

  Widget listTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 32,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      onTap: onTap, // Handle onTap action
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User profile image and background
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        // If the user is logged in, display their photo
                        User? user = snapshot.data;
                        return CircleAvatar(
                          backgroundColor: Colors.white54,
                          radius: 43,
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow,
                            radius: 40,
                            backgroundImage: NetworkImage(user?.photoURL ??
                                'https://www.example.com/default_image.jpg'),
                          ),
                        );
                      } else {
                        // If no user is logged in, display a default avatar
                        return CircleAvatar(
                          backgroundColor: Colors.white54,
                          radius: 43,
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow,
                            radius: 40,
                            child: Icon(Icons.person,
                                size: 40, color: Colors.white),
                          ),
                        );
                      }
                    }
                    return CircularProgressIndicator(); // Loading indicator while checking auth state
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Check if user is logged in and display their info
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            User? user = snapshot.data;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome ${user?.displayName ?? "Guest"}'),
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Log out the user
                                      FirebaseAuth.instance.signOut();
                                    },
                                    child: Text('Logout'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Text('Welcome Guest'),
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    },
                                    child: Text('Login'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        return CircularProgressIndicator(); // Loading state
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          listTile(
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () {
              // Handle home navigation
            },
          ),
          listTile(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () {
              // Navigate to the User Profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserProfilePage()), // Navigate to User Profile
              );
            },
          ),
          listTile(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {
              // Handle notification navigation
            },
          ),
          // Add other ListTiles as needed
        ],
      ),
    );
  }
}
