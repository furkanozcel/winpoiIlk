import 'package:flutter/material.dart';
import 'package:winpoi/core/theme/app_theme.dart';
import 'package:winpoi/features/leadboard_page/data/models/leader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeadingBoard extends StatelessWidget {
  const LeadingBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('poiBalance', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                ],
                title: const Text('Liderlik Tablosu'),
                pinned: true,
                expandedHeight: 220,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final userData =
                        users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(userData['name'] ?? ''),
                      subtitle: Text('@${userData['username'] ?? ''}'),
                      trailing: Text('${userData['poiBalance'] ?? 0} POI'),
                    );
                  },
                  childCount: users.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
