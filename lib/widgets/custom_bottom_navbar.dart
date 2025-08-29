// Removed few important lines in code for not giving complete implementation

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String activeButton;
  final Function(String) onTabSelected;
  final bool showScannerIcon;

  const CustomBottomNavBar({
    super.key,
    required this.activeButton,
    required this.onTabSelected,
    this.showScannerIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 70,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 60,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIcon(Icons.stacked_bar_chart_sharp, 'dashboard'),
                _buildIcon(Icons.group, 'profile'),
              ],
            ),
          ),

          if (showScannerIcon)
            GestureDetector(
              onTap: () => onTabSelected('BarcodeScanner'),
              child: Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.black87,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 60,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.barcode_viewfinder,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, String key) {
    return GestureDetector(
      onTap: () => onTabSelected(key),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activeButton == key ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          size: 34,
          color: activeButton == key ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
