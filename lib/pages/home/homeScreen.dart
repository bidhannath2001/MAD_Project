import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app/auth/login.dart';
import 'package:food_app/groupchat.dart';
import 'package:food_app/pages/home/drawer_side.dart';
// import 'package:food_app/pages/home/group_chat_screen.dart'; // Import the group chat screen

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> groups = []; // List to hold the group names

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  // Load user groups from Firestore
  Future<void> _loadUserGroups() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        List<dynamic> groupIds = userDoc['groups'] ?? [];
        List<String> groupNames = [];

        // Fetch group names using the group IDs
        for (var groupId in groupIds) {
          var groupDoc =
              await _firestore.collection('groups').doc(groupId).get();
          if (groupDoc.exists) {
            groupNames.add(groupDoc['groupName']);
          }
        }

        setState(() {
          groups = groupNames;
        });
      }
    }
  }

  void _createGroup() {
    TextEditingController _groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New Group"),
          content: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Enter Group Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () async {
                String groupName = _groupNameController.text.trim();
                if (groupName.isNotEmpty) {
                  try {
                    // Ensure the user document exists FIRST
                    User? user = _auth.currentUser;
                    if (user != null) {
                      // Check if user exists in Firestore
                      var userDoc = await _firestore
                          .collection('users')
                          .doc(user.uid)
                          .get();
                      if (!userDoc.exists) {
                        // If user doesn't exist, create the user document
                        await _firestore.collection('users').doc(user.uid).set({
                          'email': user.email,
                          'displayName': user.displayName,
                          'groups': [],
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      }

                      // Create the group document with the group name as the document ID
                      String groupId =
                          groupName; // Use groupName as the document ID

                      // Create the group document with the specified group name as the ID
                      await _firestore.collection('groups').doc(groupId).set({
                        'groupName': groupName,
                        'description':
                            'New group created by ${user.displayName}',
                        'members': [
                          user.uid
                        ], // Add the current user as the first member
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      // Add groupId to the user's groups list
                      await _firestore
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'groups': FieldValue.arrayUnion([groupId]),
                      });

                      // Reload groups and close the dialog
                      _loadUserGroups();
                      Navigator.of(context).pop();

                      // Show success Snackbar after group is created
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Group "$groupName" created successfully!')),
                      );
                    }
                  } catch (e) {
                    print("Error creating group: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error creating group: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid group name")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Logout method
  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Navigate to the group chat screen
  void _navigateToGroupChat(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GroupChatScreen(groupId: groupId, groupName: groupName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: DrawerSlider(), // Custom drawer
      ),
      appBar: AppBar(
        title: Text('Class Central'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout, // Logout button
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Info Section
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(
              'Welcome, ${user?.displayName ?? 'Guest'}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? 'Not Available'}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _createGroup,
              child: const Text('Create a New Group'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),

            // List of Groups
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      String groupId = groups[
                          index]; // In this case, group name is used as groupId
                      _navigateToGroupChat(groupId, groups[index]);
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: Icon(
                          Icons.group,
                          color: Colors.green,
                          size: 30,
                        ),
                        title: Text(
                          groups[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // subtitle: Text("Tap to join or view the group"),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
