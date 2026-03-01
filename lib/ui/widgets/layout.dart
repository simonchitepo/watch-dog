import 'package:flutter/material.dart';

class ResponsiveGutter extends StatelessWidget {
  final Widget child;
  const ResponsiveGutter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w >= 900 ? 24.0 : 16.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: child,
        ),
      ),
    );
  }
}
