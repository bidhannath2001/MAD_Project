import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getGroupMembers(String groupId) async {
    try {
      final groupDoc =
          await _firestore.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        return {'totalMembers': 0, 'members': []};
      }

      List<dynamic> memberIds = groupDoc.data()?['members'] ?? [];

      if (memberIds.isEmpty) {
        return {'totalMembers': 0, 'members': []};
      }

      // Fetch all users in ONE query
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: memberIds)
          .get();

      final members = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'No Name',
          'email': data['email'] ?? 'No Email',
        };
      }).toList();

      return {
        'totalMembers': members.length,
        'members': members,
      };
    } catch (e) {
      debugPrint("Error fetching members: $e");
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
        future: getGroupMembers(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['totalMembers'] == 0) {
            return const Center(child: Text('No members found.'));
          }

          final members = snapshot.data!['members'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Members: ${members.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(member['displayName']),
                          subtitle: Text(member['email']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
