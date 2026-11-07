import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // Mock data for UI demonstration
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Rahim', 'level': 12, 'isOnline': true, 'avatar': Colors.blue},
    {'name': 'Karim', 'level': 8, 'isOnline': false, 'avatar': Colors.green},
    {'name': 'Sabbir', 'level': 25, 'isOnline': true, 'avatar': Colors.orange},
  ];

  final List<Map<String, dynamic>> _requests = [
    {'name': 'Nabil', 'level': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('FRIENDS'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add, color: AppColors.blue),
              onPressed: () => _showSearchDialog(context),
            )
          ],
          bottom: const TabBar(
            labelColor: AppColors.blue,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.blue,
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
              Tab(text: 'Recent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendList(),
            _buildRequestList(),
            const Center(child: Text('No recent players yet', style: TextStyle(color: AppColors.textLight))),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendList() {
    if (_friends.isEmpty) {
      return const Center(child: Text('No friends yet. Invite some!'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: friend['avatar'],
                  child: Text(friend['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                if (friend['isOnline'])
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(friend['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Level ${friend['level']} • ${friend['isOnline'] ? "Online" : "Offline"}', style: TextStyle(color: friend['isOnline'] ? AppColors.green : AppColors.textLight, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.blue),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(friendName: friend['name']))),
                ),
                IconButton(
                  icon: const Icon(Icons.sports_esports, color: AppColors.green),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match invite sent!'))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestList() {
    if (_requests.isEmpty) return const Center(child: Text('No pending requests'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final req = _requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.textLight, child: Text(req['name'][0], style: const TextStyle(color: Colors.white))),
            title: Text(req['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Level ${req['level']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: AppColors.green),
                  onPressed: () {
                    setState(() {
                      _friends.add({'name': req['name'], 'level': req['level'], 'isOnline': true, 'avatar': Colors.purple});
                      _requests.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.red),
                  onPressed: () => setState(() => _requests.removeAt(index)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('SEARCH PLAYER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Player ID or Name',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search backend coming soon!')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, minimumSize: const Size(double.infinity, 50)),
                child: const Text('SEARCH'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
