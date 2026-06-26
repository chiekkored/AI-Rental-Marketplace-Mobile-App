import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:intl/intl.dart';

mixin TextFieldsMixin {
  String? validateField(String? value, {required String label}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!GetUtils.isPhoneNumber(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }

    final DateTime dob;
    try {
      dob = DateFormat('MMMM dd, yyyy').parseStrict(value.trim());
    } catch (_) {
      return 'Select a valid date of birth';
    }

    if (DateTime.now().difference(dob).inDays < 6570) {
      return 'You must be at least 18 years old';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$',
    ).hasMatch(value)) {
      return 'Password must include uppercase, lowercase, number, and special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Password confirmation is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
