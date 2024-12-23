class Validators {
  static String? validateBookTitle(String? value) {
    if ((value?.trim().length ?? 0) < 2) {
      return 'Book title must be at least 2 characters';
    }
    return null;
  }

  static String? validateAuthor(String? value) {
    if ((value?.trim().length ?? 0) < 2) {
      return 'Author name must be at least 2 characters';
    }
    return null;
  }

  static String? validateReview(String? value) {
    if ((value?.trim().length ?? 0) < 10) {
      return 'Review must be at least 10 characters';
    }
    return null;
  }
}