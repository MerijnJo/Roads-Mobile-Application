import 'package:flutter/material.dart';

import '../models/route_stop.dart';

class RouteStopMarker extends StatelessWidget {
  const RouteStopMarker({
    required this.stop,
    required this.isPrimary,
    required this.onTap,
    super.key,
  });

  final RouteStop stop;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: stop.name,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF007A63) : colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isPrimary ? Colors.white : const Color(0xFF007A63),
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isPrimary ? Icons.flag : Icons.place,
            color: isPrimary ? Colors.white : const Color(0xFF007A63),
            size: isPrimary ? 26 : 24,
          ),
        ),
      ),
    );
  }
}
