import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_budget/util/appbar.dart';
import 'package:smart_budget/util/feature_tile.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Convenience colors
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF7A7A7A);
  static const Color _green = Color(0xFF48B050);
  static const Color _greenSoft = Color(0xFFEAF6EC);
  static const Color _goldSoft = Color(0xFFF4E7B7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            _header(context),
            const SizedBox(height: 14),
            _aboutCard(),
            const SizedBox(height: 14),
            _featuresGrid(),
            const SizedBox(height: 14),
            _visualShowcase(context),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onTap: (i) => {},
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // more rounded
            child: Container(
              color: _greenSoft,
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                "assets/icons/smart_budget_logo.svg",
                width: 72, // bigger, cleaner
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Budget",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Turn spending into progress.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Smart Budget is a local app for tracking spendings in a nice way. "
            "It helps you stay organized with payment categorizations and adds "
            "gamification through badge rewards — so financial responsibility feels "
            "fun and rewarding instead of stressful.",
            style: TextStyle(
              fontSize: 14.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresGrid() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What you get",
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _FeatureTile(
                icon: Icons.receipt_long_rounded,
                title: "Easy tracking",
                subtitle: "Log spends quickly.",
                tint: _greenSoft,
              ),
              _FeatureTile(
                icon: Icons.category_rounded,
                title: "Categories",
                subtitle: "Know where money goes.",
                tint: Color(0xFFF1F1F1),
              ),
              _FeatureTile(
                icon: Icons.emoji_events_rounded,
                title: "Badges",
                subtitle: "Progress feels rewarding.",
                tint: _goldSoft,
              ),
              _FeatureTile(
                icon: Icons.insights_rounded,
                title: "Clear insights",
                subtitle: "See habits at a glance.",
                tint: Color(0xFFEFF5FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _visualShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "A quick look",
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 10),
        _imageCard("assets/icons/budget_picture.png"),
        const SizedBox(height: 12),
        _imageCard("assets/icons/finance_tracking.png"),
      ],
    );
  }

  Widget _imageCard(String asset) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: AboutPage._text),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AboutPage._text,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AboutPage._muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
