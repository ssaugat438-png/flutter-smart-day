/// Input and form validators for SmartDay.
class Validators {
  /// Validates reminder title.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a reminder title.';
    }
    if (value.trim().length < 2) {
      return 'Title must be at least 2 characters long.';
    }
    if (value.trim().length > 100) {
      return 'Title cannot exceed 100 characters.';
    }
    return null;
  }

  /// Validates optional description.
  static String? validateDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description cannot exceed 500 characters.';
    }
    return null;
  }

  /// Validates category name for custom categories.
  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a category name.';
    }
    if (value.trim().length < 2) {
      return 'Category name must be at least 2 characters.';
    }
    if (value.trim().length > 30) {
      return 'Category name cannot exceed 30 characters.';
    }
    return null;
  }
}
