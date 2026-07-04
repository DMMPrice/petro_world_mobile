class AppVersionConfig {
  AppVersionConfig._();

  static String _currentVersionNo = '1.0.0';
  static String _previousVersionNo = '1.0.0';

  static String get currentVersionNo => _currentVersionNo;
  static String get previousVersionNo => _previousVersionNo;

  static void recordVersionChange(String nextVersionNo) {
    final normalizedVersion = nextVersionNo.trim();
    if (normalizedVersion.isEmpty || normalizedVersion == _currentVersionNo) {
      return;
    }

    _previousVersionNo = _currentVersionNo;
    _currentVersionNo = normalizedVersion;
  }
}
