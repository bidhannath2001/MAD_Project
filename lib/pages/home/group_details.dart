import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupDetailsScreen({required this.groupId, required this.groupName});

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to get total members and their details from Firestore
  Future<Map<String, dynamic>> getGroupMembers(String groupId) async {
    try {
      // Get the group document from Firestore
      DocumentSnapshot groupDoc =
          await _firestore.collection('groups').doc(groupId).get();

      // Ensure the group exists
      if (groupDoc.exists) {
        // Get the members list (list of user IDs)
        List<dynamic> memberIds = groupDoc['members'] ?? [];

        // Retrieve user details for each member
        List<Map<String, dynamic>> memberDetails = [];
        for (var memberId in memberIds) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            // You can change this to display other user details like email or profile picture
            memberDetails.add({
              'userId': memberId,
              'displayName': userDoc['displayName'] ?? 'No Name',
              'email': userDoc['email'] ?? 'No Email',
            });
          }
        }

        // Return a map with the total members count and the member details
        return {
          'totalMembers': memberIds.length,
          'members': memberDetails,
        };
      } else {
        print("Group not found");
        return {'totalMembers': 0, 'members': []};
      }
    } catch (e) {
      print("Error getting group members: $e");
      return {'totalMembers': 0, 'members': []};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getGroupMembers(widget.groupId), // Get members data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['totalMembers'] == 0) {
            return Center(child: Text('No members found.'));
          } else {
            // Get the total members and their details
            int totalMembers = snapshot.data!['totalMembers'];
            List<Map<String, dynamic>> members = snapshot.data!['members'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display total members
                  Text(
                    'Total Members: $totalMembers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Display the member details (name and email)
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        var member = members[index];
                        return ListTile(
                          title: Text(member['displayName']),
                          subtitle: Text(member['email']),
                          // Optionally, you can show their profile picture here if available
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
