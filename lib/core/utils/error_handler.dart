class ErrorHandler {
  static String getReadableErrorMessage(dynamic error) {
    final errStr = error.toString();
    if (errStr.contains('401') || errStr.toLowerCase().contains('unauthorized') || errStr.toLowerCase().contains('key')) {
      return 'Authentication failed. Please verify your API key configuration.';
    }
    if (errStr.contains('429') || errStr.toLowerCase().contains('rate limit') || errStr.toLowerCase().contains('exhausted')) {
      return 'Rate limit exceeded. Please try again shortly.';
    }
    if (errStr.contains('503') || errStr.toLowerCase().contains('unavailable') || errStr.toLowerCase().contains('overloaded')) {
      return 'Gemini service is currently overloaded. Please try again.';
    }
    if (errStr.toLowerCase().contains('socketexception') || errStr.toLowerCase().contains('network') || errStr.toLowerCase().contains('connection') || errStr.toLowerCase().contains('dioexception')) {
      return 'Network connection issue. Please check your internet/API connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
