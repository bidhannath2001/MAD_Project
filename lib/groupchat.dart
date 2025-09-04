import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app/pages/home/group_details.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen(
      {super.key, required this.groupId, required this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message method
  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user

      if (user != null) {
        // Add message to Firestore under the correct group ID
        try {
          await _firestore
              .collection('groups')
              .doc(widget.groupId) // Reference the specific group
              .collection('messages')
              .add({
            'sender':
                user.displayName ?? 'Anonymous', // Get the user's display name
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'senderPhoto': user.photoURL, // Store the sender's photo URL
          });
          // Clear the text field after sending the message
          _messageController.clear();
        } catch (e) {
          print("Error sending message: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error sending message: $e")),
          );
        }
      } else {
        // Handle case where user is not logged in
        print("No user is logged in");
      }
    }
  }

  void _addToGroup(String groupId) async {
    TextEditingController _memberController = TextEditingController();

    // Check if the group document exists first
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      // If the group does not exist, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group does not exist')),
      );
      return;
    }

    // Get current group members to avoid duplicates
    final currentMembers = List<String>.from(groupDoc.data()?['members'] ?? []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add to ${widget.groupName}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _memberController,
                decoration: InputDecoration(
                  labelText: 'Enter Member Email',
                  hintText: 'user@example.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Only users who have already registered can be added",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                String email = _memberController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    // First check if user exists
                    var userQuery = await _firestore
                        .collection('users')
                        .where('email', isEqualTo: email)
                        .get();

                    if (userQuery.docs.isNotEmpty) {
                      var userDoc = userQuery.docs.first;
                      String userId = userDoc.id;

                      // Check if user is already in the group
                      if (currentMembers.contains(userId)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User already in this group')),
                        );
                        return;
                      }

                      // Use Firestore transaction to add user to group
                      await _firestore.runTransaction((transaction) async {
                        DocumentSnapshot groupSnapshot = await transaction.get(
                          _firestore.collection('groups').doc(groupId),
                        );

                        if (!groupSnapshot.exists) {
                          throw Exception("Group does not exist");
                        }

                        // Add user to the group
                        transaction.update(
                          _firestore.collection('groups').doc(groupId),
                          {
                            'members': FieldValue.arrayUnion([userId]),
                          },
                        );

                        // Add group to user's groups list
                        transaction.update(
                          _firestore.collection('users').doc(userId),
                          {
                            'groups': FieldValue.arrayUnion([groupId]),
                          },
                        );
                      });

                      // Success message and close dialog
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('$email added to group successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'User not found. They must register first.')),
                      );
                    }
                  } catch (e) {
                    print("Error adding member: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error adding member: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _leaveGroup(String groupId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Get the current group document
        DocumentReference groupRef =
            _firestore.collection('groups').doc(groupId);
        DocumentSnapshot groupDoc = await groupRef.get();

        // Ensure the group exists
        if (groupDoc.exists) {
          // Get the current list of members
          List<dynamic> members = groupDoc['members'];

          // Check if the user is part of the group
          if (members.contains(user.uid)) {
            // Remove the user from the group's members list
            await groupRef.update({
              'members': FieldValue.arrayRemove([user.uid]),
            });

            // Remove the group from the user's list of groups
            await _firestore.collection('users').doc(user.uid).update({
              'groups': FieldValue.arrayRemove([groupId]),
            });

            // Check if there are no members left in the group, delete the group
            if (members.length == 1) {
              await groupRef.delete();
            }

            // Show a success Snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You have left the group "$groupId".')),
            );

            setState(() {});

            // Optionally, navigate the user to another screen or reload the current screen
            Navigator.of(context).pop(); // Close the group chat screen
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You are not a member of this group.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Group does not exist.')),
          );
        }
      } catch (e) {
        print("Error leaving group: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error leaving group: $e")),
        );
      }
    }
  }

  // Show options in dialog (For adding members)
  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Add Member'),
                onTap: () {
                  Navigator.pop(context);
                  _addToGroup(widget.groupId);
                },
              ),
              ListTile(
                title: Text('Leave Group'),
                onTap: () {
                  Navigator.pop(context);
                  _leaveGroup(widget.groupId);
                },
              ),
              ListTile(
                title: Text('Members'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailsScreen(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 250, 249),
        title: Text(widget.groupName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.video_call),
          ),
          IconButton(
            onPressed:
                _showOptionsDialog, // Show options dialog on pressing the button
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/R.jpeg'), // Specify the image path
            fit: BoxFit.cover, // This ensures the image covers the whole screen
          ),
        ),
        child: Column(
          children: [
            // Display the messages (Above the TextField)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index]['message'];
                      var sender = messages[index]['sender'];
                      var senderPhoto = messages[index]['senderPhoto'] ?? '';
                      var timestamp = messages[index]['timestamp'];

                      // Format timestamp into readable format
                      String time = timestamp != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                                  timestamp.seconds * 1000)
                              .toLocal()
                              .toString()
                          : '';

                      // Determine message alignment based on sender
                      bool isCurrentUser = sender ==
                          FirebaseAuth.instance.currentUser?.displayName;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isCurrentUser)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: senderPhoto.isNotEmpty
                                      ? NetworkImage(senderPhoto)
                                      : AssetImage('assets/default_avatar.png')
                                          as ImageProvider,
                                ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sender,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.blue[200]
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(message,
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  SizedBox(height: 4),
                                  Text(time,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // TextField to input message (Below the messages)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _sendMessage, // Send message on press
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
