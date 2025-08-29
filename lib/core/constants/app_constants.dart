class AppConstants {
  static const String appName = 'FinGuard AI';
  static const String appVersion = '1.0.0';

  // API
  static const String backendBaseUrl = 'http://10.0.2.2:8000'; // FastAPI local
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  static const String claudeModel = 'claude-sonnet-4-6';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String goalsCollection = 'goals';
  static const String profileCollection = 'financial_profiles';

  // Shared prefs keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keyClaudeApiKey = 'claude_api_key';

  // Transaction categories  (max 12 expense, 10 income)
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Health & Medical',
    'Education',
    'Rent & Housing',
    'Subscriptions',
    'Travel',
    'Fitness',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Rental',
    'Bonus',
    'Side Hustle',
    'Refund',
    'Other',
  ];
}
