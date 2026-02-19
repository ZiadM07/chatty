class Validator {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }

    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }

    String username = value.trim();

    // Minimum length
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    // Maximum length
    if (username.length > 20) {
      return 'Username cannot exceed 20 characters';
    }

    // No spaces allowed
    if (username.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    // Allowed characters: letters, numbers, underscore, dot
    final regex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!regex.hasMatch(username)) {
      return 'Only letters, numbers, underscores, and dots are allowed';
    }

    return null; // OK
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }
}
