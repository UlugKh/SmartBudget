import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;  
  /// Current Index represents what page is active
  /*
  0 = Home
  1 = Monitoring
  2 = Add payment
  3 = Rewards
  4 = About
  */ 
  final ValueChanged<int> onTap;

//Optional
  final Color iconColor;
  final TextStyle? labelStyle;
  final double height;
  final Color backgroundColor;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.iconColor = const Color(0xFF222222),
    this.labelStyle,
    this.height = 100,
    this.backgroundColor = Colors.white,
  });

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveLabelStyle = labelStyle ??
        const TextStyle(
          fontSize: 11,
          height: 1.2,
          color: Color(0xFF222222),
          fontWeight: FontWeight.w500,
        );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(
          top: BorderSide(
            color: Color(0x11000000), // very subtle separation
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // tiny shadow for lift
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
              icon: Icons.home_rounded,
              label: "Home",
              iconColor: iconColor,
              iconSize: _iconSize,
              labelStyle: effectiveLabelStyle,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
              icon: Icons.monitor_rounded, 
              label: "Monitoring",
              iconColor: iconColor,
              iconSize: _iconSize,
              labelStyle: effectiveLabelStyle,
            ),
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              onTap: onTap,
              icon: Icons.add_circle_outline_rounded,
              label: "Add payment",
              iconColor: iconColor,
              iconSize: _iconSize,
              labelStyle: effectiveLabelStyle,
            ),
            _NavItem(
              index: 3,
              currentIndex: currentIndex,
              onTap: onTap,
              icon: Icons.card_giftcard_rounded, 
              label: "Rewards",
              iconColor: iconColor,
              iconSize: _iconSize,
              labelStyle: effectiveLabelStyle,
            ),
            _NavItem(
              index: 4,
              currentIndex: currentIndex,
              onTap: onTap,
              icon: Icons.info_outline_rounded, 
              label: "About",
              iconColor: iconColor,
              iconSize: _iconSize,
              labelStyle: effectiveLabelStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData icon;
  final String label;
  final Color iconColor;
  final double iconSize;
  final TextStyle labelStyle;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconSize,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;

    return Expanded(
      child: InkResponse(
        onTap: () => onTap(index),
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize - 2,
                color: iconColor, // same for all, as requested
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: labelStyle.copyWith(
                  fontSize: (labelStyle.fontSize ?? 11) - 0.5, 
                  height: 1.0,
                  color: labelStyle.color, // keep consistent
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : labelStyle.fontWeight,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
