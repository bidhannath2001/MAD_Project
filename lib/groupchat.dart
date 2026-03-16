import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/home/data/group_chat_repository.dart';
import 'pages/home/group_details.dart';

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
  final GroupChatRepository _repository = GroupChatRepository();

  // Send message method
  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        await _repository.sendMessage(widget.groupId, message);
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending message: $e")),
        );
      }
    }
  }

  void _addToGroup(String groupId) async {
    TextEditingController _memberController = TextEditingController();

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
                    await _repository.addMemberByEmail(groupId, email);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$email added to group successfully')),
                    );
                  } catch (e) {
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
    try {
      await _repository.leaveGroup(groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have left the group "$groupId".')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error leaving group: $e")),
      );
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
        decoration: const BoxDecoration(
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
                stream: _repository.messagesStream(widget.groupId),
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
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? const Color(0xffDCF8C6)
                                          : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: isCurrentUser
                                            ? const Radius.circular(16)
                                            : const Radius.circular(4),
                                        bottomRight: isCurrentUser
                                            ? const Radius.circular(4)
                                            : const Radius.circular(16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: SelectableText(
                                      message,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
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
