import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7FF5);
  static const Color teal = Color(0xFF00B894);
  static const Color pink = Color(0xFFE84393);

  // Status
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDAA47);
  static const Color error = Color(0xFFFF5252);
  static const Color income = Color(0xFF00B894);
  static const Color expense = Color(0xFFFF5252);

  // Dark theme
  static const Color darkBg = Color(0xFF0D0D1B);
  static const Color darkCard = Color(0xFF1C1C2E);
  static const Color darkCardLight = Color(0xFF252538);
  static const Color darkBorder = Color(0xFF2E2E45);

  // Light theme
  static const Color lightBg = Color(0xFFF4F4FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E8F0);

  // Category icon colors
  static const Color catHousing = Color(0xFF6C5CE7);
  static const Color catFood = Color(0xFFE17055);
  static const Color catShopping = Color(0xFF00B894);
  static const Color catTransport = Color(0xFF00CEC9);
  static const Color catEntertain = Color(0xFFFDAA47);
  static const Color catHealth = Color(0xFFE84393);
  static const Color catEducation = Color(0xFF74B9FF);
  static const Color catUtilities = Color(0xFF55EFC4);
  static const Color catSubscription = Color(0xFFA29BFE);
  static const Color catOther = Color(0xFFB2BEC3);

  static const Gradient headerGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00B894)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient goalGradient = LinearGradient(
    colors: [Color(0xFFE84393), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'rent & housing':   return catHousing;
      case 'food & dining':    return catFood;
      case 'shopping':         return catShopping;
      case 'transport':        return catTransport;
      case 'entertainment':    return catEntertain;
      case 'health & medical': return catHealth;
      case 'education':        return catEducation;
      case 'bills & utilities':return catUtilities;
      case 'subscriptions':    return catSubscription;
      case 'travel':           return const Color(0xFF00B2D6);
      case 'fitness':          return const Color(0xFF2ECC71);
      // Income
      case 'salary':           return income;
      case 'freelance':        return const Color(0xFF74B9FF);
      case 'business':         return const Color(0xFFA29BFE);
      case 'investment':       return const Color(0xFF00CEC9);
      case 'gift':             return const Color(0xFFE84393);
      case 'rental':           return catFood;
      case 'bonus':            return catEntertain;
      case 'side hustle':      return const Color(0xFFF9CA24);
      case 'refund':           return const Color(0xFF00B2D6);
      default:                 return catOther;
    }
  }

  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent & housing':   return Icons.home_rounded;
      case 'food & dining':    return Icons.restaurant_rounded;
      case 'shopping':         return Icons.shopping_bag_rounded;
      case 'transport':        return Icons.directions_car_rounded;
      case 'entertainment':    return Icons.movie_rounded;
      case 'health & medical': return Icons.favorite_rounded;
      case 'education':        return Icons.school_rounded;
      case 'bills & utilities':return Icons.bolt_rounded;
      case 'subscriptions':    return Icons.subscriptions_rounded;
      case 'travel':           return Icons.flight_rounded;
      case 'fitness':          return Icons.fitness_center_rounded;
      // Income
      case 'salary':           return Icons.account_balance_wallet_rounded;
      case 'freelance':        return Icons.laptop_rounded;
      case 'business':         return Icons.storefront_rounded;
      case 'investment':       return Icons.trending_up_rounded;
      case 'gift':             return Icons.card_giftcard_rounded;
      case 'rental':           return Icons.home_work_rounded;
      case 'bonus':            return Icons.emoji_events_rounded;
      case 'side hustle':      return Icons.lightbulb_rounded;
      case 'refund':           return Icons.replay_rounded;
      default:                 return Icons.attach_money_rounded;
    }
  }
}

class AppTheme {
  static ThemeData get darkTheme => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8888AA) : const Color(0xFF666688);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.teal,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: card,
        onSurface: textPrimary,
      ),
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
        labelSmall: TextStyle(color: textSecondary, fontSize: 11),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary, fontFamily: 'Poppins'),
        hintStyle: TextStyle(color: textSecondary, fontFamily: 'Poppins'),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: AppColors.primary.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
          color: s.contains(WidgetState.selected) ? AppColors.primary : textSecondary,
        )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? AppColors.primary : textSecondary,
          size: 22,
        )),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
    );
  }
}
