import 'package:flutter/material.dart';
import 'package:winpoi/features/leadboard_page/data/models/leader.dart';

class LeadingBoard extends StatelessWidget {
  const LeadingBoard({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek veri
    final leaders = List.generate(
      30,
      (index) => Leader(
        id: 'id_$index',
        name: 'Kullanıcı ${index + 1}',
        avatarUrl: 'https://example.com/avatar$index.jpg',
        rank: index + 1,
        totalPrizeCount: 30 - index,
        poiBalance: (1000 - (index * 25)).toDouble(),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'En İyi 30 Oyuncu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tebrikler! En iyi oyuncular arasındasınız.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.card_giftcard,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Çok Özelsin Sadece Bekle;);)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLeaderListTile(leaders[index]),
                childCount: leaders.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderListTile(Leader leader) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '#${leader.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      leader.rank <= 3 ? Colors.orange : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: NetworkImage(leader.avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
              child: const Icon(Icons.person),
            ),
          ],
        ),
        title: Text(
          leader.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${leader.totalPrizeCount} Ödül Kazandı',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${leader.poiBalance.toStringAsFixed(0)} POI',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
