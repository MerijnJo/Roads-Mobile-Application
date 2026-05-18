import 'package:flutter/material.dart';

import '../models/point_of_interest.dart';

class PoiMarker extends StatelessWidget {
  const PoiMarker({
    required this.poi,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final PointOfInterest poi;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: poi.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: isSelected ? 1.12 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.place,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
