import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// App-wide background: dark mountain image fading into [AppColors.background].
/// Used via [MaterialApp.builder] so every route shares the same backdrop.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final heroHeight = topPad + 220;
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/hero_bg.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.25),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.15),
                        AppColors.background.withValues(alpha: 0.55),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
