import 'package:flutter/material.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> gameNames = [
      'MacBook Pro M3 ',
      'Samsung S24 Ultra ',
      'PlayStation 5 ',
      'iPad Pro M2 ',
      'Asus ROG Gaming Laptop ',
      'iPhone 15 Pro Max ',
      'Dell XPS 15 ',
      'Nintendo Switch OLED ',
      'AirPods Pro 2 ',
      'MSI Titan GT77 ',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: const Text(
                  'Oyun Geçmişi',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6600),
                const Color(0xFFFF6600).withOpacity(0.95),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFF6600),
                  const Color(0xFFFF6600).withOpacity(0.0),
                ],
              ),
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 80,
              16,
              24,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: gameNames.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 300 + (index * 50)),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: _buildEnhancedGameHistoryCard(
                        date: DateTime.now().subtract(Duration(days: index)),
                        gameName: gameNames[index],
                        result: index % 3 == 0 ? 'Kazandın!' : 'Kaybettin',
                        earnedPoi: (100 - (index * 5)).toDouble(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGameHistoryCard({
    required DateTime date,
    required String gameName,
    required String result,
    required double earnedPoi,
  }) {
    final bool isWinner = result == 'Kazandın!';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner
              ? const Color(0xFFFF6600).withOpacity(0.2)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isWinner
                ? const Color(0xFFFF6600).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: isWinner
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6600).withOpacity(0.12),
                        const Color(0xFFFF6600).withOpacity(0.05),
                      ],
                    )
                  : null,
              color: !isWinner ? Colors.grey.shade50 : null,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isWinner
                            ? const Color(0xFFFF6600).withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: isWinner
                            ? const Color(0xFFFF6600)
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        color: isWinner
                            ? const Color(0xFFFF6600)
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isWinner
                        ? LinearGradient(
                            colors: [
                              const Color(0xFFFF6600),
                              const Color(0xFFFF6600).withOpacity(0.9),
                            ],
                          )
                        : null,
                    color: !isWinner ? Colors.grey.shade200 : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isWinner
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6600).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: isWinner ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  gameName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWinner ? 22 : 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isWinner
                        ? const Color(0xFFFF6600)
                        : Colors.black.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6600).withOpacity(0.12),
                        const Color(0xFFFF6600).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6600).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6600).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.currency_lira,
                          size: 20,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '+$earnedPoi POI',
                        style: TextStyle(
                          color: const Color(0xFFFF6600),
                          fontWeight: FontWeight.w800,
                          fontSize: isWinner ? 20 : 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
