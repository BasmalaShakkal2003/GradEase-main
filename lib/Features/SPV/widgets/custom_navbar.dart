import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = MediaQuery.textScaleFactorOf(context).clamp(0.8, 1.2);

    // Calculate responsive dimensions
    final navBarWidth = screenWidth * 0.65; // 65% of screen width
    final navBarHeight = navBarWidth * 0.26; // Maintain aspect ratio
    final iconContainerSize = navBarWidth * 0.22; // 22% of nav bar width
    final iconSize = navBarWidth * 0.12; // 12% of nav bar width

    return Container(
      width: navBarWidth,
      height: navBarHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF011226),
        borderRadius: BorderRadius.circular(navBarHeight / 2),
        border: Border.all(
          color: Colors.white,
          width: 1 * scaleFactor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8 * scaleFactor,
            offset: Offset(0, 4 * scaleFactor),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.group, 0, iconContainerSize, iconSize),
          _buildNavItem(Icons.home, 1, iconContainerSize, iconSize),
          _buildNavItem(Icons.person, 2, iconContainerSize, iconSize),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, double size, double iconSize) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        width: size,
        height: size * 0.82, // Maintain original aspect ratio
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? const Color(0xFF09316E)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
