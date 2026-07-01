import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trigger transition callback once the widget is laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        _navigateToDashboard(context);
      });
    });

    return Scaffold(
      body: AppTheme.radialGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Styled Custom App Logo
              _buildLogo(),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'SMARTSPEND',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: AppTheme.textPrimary,
                  shadows: [
                    Shadow(color: AppTheme.primaryAccent, blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'AI-Powered Expense Management',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 60),
              // Glow loading bar
              _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    const double size = 120;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppTheme.primaryAccent.withOpacity(0.3), Colors.transparent],
          radius: 0.8,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer neon glowing circle
            Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryAccent, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryAccent.withOpacity(0.4),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Wallet icon symbol
            Icon(
              Icons.account_balance_wallet_outlined,
              size: size * 0.42,
              color: AppTheme.textPrimary,
            ),
            // Glowing coin dot (floating)
            Positioned(
              top: size * 0.23,
              right: size * 0.23,
              child: Container(
                width: size * 0.16,
                height: size * 0.16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cyanAccent,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyanAccent,
                      blurRadius: 12,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 140,
      height: 3,
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          Container(
            width: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryAccent, AppTheme.cyanAccent],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyanAccent.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
