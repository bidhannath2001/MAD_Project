import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loading_indicator.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/data/group_chat_repository.dart';
import '../../features/home/models/group.dart';
import '../../features/home/providers/group_list_provider.dart';
import '../../groupchat.dart';
import 'drawer_side.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Group> groups = []; // List to hold the user groups
  final GroupChatRepository _repository = GroupChatRepository();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupListProvider>().loadGroups();
    });
  }

  // Load user groups from Firestore
  Future<void> _loadUserGroups() async {
    final provider = context.read<GroupListProvider>();
    await provider.loadGroups();
    setState(() {
      groups = provider.groups;
    });
  }

  void _createGroup() {
    final TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.green,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Create New Group",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Give your study group a meaningful name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: groupNameController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Enter group name",
                    prefixIcon: const Icon(Icons.edit_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (_) async {
                    final groupName = groupNameController.text.trim();
                    if (groupName.isEmpty) return;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final groupName = groupNameController.text.trim();

                          if (groupName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a valid group name"),
                              ),
                            );
                            return;
                          }

                          try {
                            await context
                                .read<GroupListProvider>()
                                .createGroup(groupName);
                            await _loadUserGroups();
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Group "$groupName" created successfully!',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error creating group: $e"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Create',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Logout method
  void _logout() async {
    await context.read<AuthProvider>().signOut();
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
      drawer: const Drawer(
        child: DrawerSlider(),
      ),
      appBar: CustomAppBar(
        titleText: 'Class Central',
        actions: [
          IconButton(
            icon:const  Icon(Icons.exit_to_app),
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
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome, ${user?.displayName ?? 'Guest'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? 'Not Available'}',
              style:const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Consumer<GroupListProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.groups.isEmpty) {
                    return const AppLoadingIndicator(
                      message: 'Loading your groups...',
                    );
                  }
                  if (provider.error != null && provider.groups.isEmpty) {
                    return AppErrorView(
                      message: provider.error!,
                      onRetry: () => provider.loadGroups(),
                    );
                  }
                  if (provider.groups.isEmpty) {
                    return const AppEmptyView(
                      message: 'No groups yet. Create your first group!',
                    );
                  }
                  final groups = provider.groups;
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return InkWell(
                        onTap: () {
                          _navigateToGroupChat(group.id, group.name);
                        },
                        child: Card(
                          shadowColor: Colors.greenAccent,
                          elevation: 0.5,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.group,
                              color: Colors.green,
                              size: 30,
                            ),
                            title: Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: StreamBuilder<String?>(
                              stream: _repository.getLastMessageStream(group.id),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text(
                                    'No messages yet',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  );
                                }

                                return Text(
                                  snapshot.data!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.green,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        backgroundColor: Colors.green,
        elevation: 4,
        tooltip: 'Create Group',
        child: const Icon(
          Icons.group_add,
          color: Colors.white,
        ),
      ),
    );
  }
}
