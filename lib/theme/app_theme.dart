import 'package:flutter/material.dart';
import 'dart:ui';

class AppTheme {
  // Primary Color Palette (Foodi App Inspired)
  static const Color primaryOrange = Color(0xFFFF6B35); // Vibrant orange like foodi
  static const Color primaryBlue = Color(0xFF1E90FF);
  static const Color accentOrange = Color(0xFFFF8C42); // Lighter orange
  static const Color accentBlue = Color(0xFF4169E1);
  // Teal Palette (added for references across the app)
  static const Color primaryTeal = Color(0xFF00BFA5); // Teal A700
  static const Color accentTeal = Color(0xFF26A69A); // Teal 400
  
  // Background Colors (Clean White Theme)
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors (Foodi Style)
  static const Color textPrimary = Color(0xFF2C3E50); // Dark gray
  static const Color textSecondary = Color(0xFF7F8C8D); // Light gray
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Health Status Colors
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningOrange = Color(0xFFFF6B35);
  static const Color errorRed = Color(0xFFE74C3C);
  
  // Risk Assessment Colors
  static const Color lowRiskGreen = Color(0xFF2ECC71);
  static const Color moderateRiskOrange = Color(0xFFF39C12);
  static const Color highRiskRed = Color(0xFFE74C3C);

  // Additional Colors
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF6C757D);
  static const Color accentPurple = Color(0xFF6F42C1);
  
  // Foodi App Specific Colors
  static const Color foodiOrange = Color(0xFFFF6B35);
  static const Color foodiBackground = Color(0xFFFFFFFF);
  static const Color foodiCardShadow = Color(0x1A000000); // 10% opacity
  static const Color foodiLightShadow = Color(0x0D000000); // 5% opacity

  // Home-specific aliases to keep older references working
  static const Color homeAccentOrange = accentOrange;
  static const Color homeCardShadow = foodiCardShadow;
  static const Color homeBackground = foodiBackground;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: foodiBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 8,
        shadowColor: foodiCardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: textWhite,
          elevation: 8,
          shadowColor: primaryOrange.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  static BoxDecoration get glassmorphismDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static Widget createGlassCard({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: glassmorphismDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget createHealthCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    bool isAnimated = false,
  }) {
    return createGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey(value),
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget createStatusIndicator({
    required bool isConnected,
    required String deviceName,
  }) {
    return createGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? successGreen : errorRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: isConnected ? successGreen : errorRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (deviceName.isNotEmpty)
                  Text(
                    deviceName,
                    style: const TextStyle(color: textSecondary, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget createAnimatedButton({
    required String text,
    VoidCallback? onPressed,
    required bool isLoading,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primaryTeal,
          foregroundColor: textColor ?? Colors.white,
          elevation: isLoading ? 4 : 8,
          shadowColor: (backgroundColor ?? primaryTeal).withOpacity(0.3),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(text),
      ),
    );
  }

  static Widget createShimmerEffect({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
        ),
      ),
      child: child,
    );
  }

  static List<Color> get healthGradient => [
    primaryTeal,
    accentTeal,
    primaryBlue,
    accentBlue,
  ];

  static List<Color> get riskGradient => [
    lowRiskGreen,
    moderateRiskOrange,
    highRiskRed,
  ];

  // Foodi App Consistent Styling Methods
  static BoxDecoration get foodiCardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: foodiCardShadow,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get foodiButtonDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: foodiLightShadow,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get foodiOrangeDecoration => BoxDecoration(
    color: primaryOrange,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryOrange.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get foodiGradientDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryOrange, accentOrange],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryOrange.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Foodi App Text Styles
  static const TextStyle foodiTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle foodiSubtitleStyle = TextStyle(
    fontSize: 18,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle foodiCardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle foodiCardValueStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle foodiCardSubtitleStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle foodiButtonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textWhite,
  );

  static const TextStyle foodiOrangeTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryOrange,
  );

  // Consistent Icon Styles
  static Widget createHomeIcon({
    required IconData icon,
    required Color color,
    double size = 24,
    bool withBackground = true,
  }) {
    if (!withBackground) {
      return Icon(icon, color: color, size: size);
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }

  // Consistent Loading Widget
  static Widget createLoadingIndicator({Color? color, double size = 20}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? primaryTeal),
      ),
    );
  }

  // Consistent Error Widget
  static Widget createErrorWidget({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: errorRed.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
