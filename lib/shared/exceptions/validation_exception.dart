class ValidationError {
  final Map<String, List<String>> errors;

  ValidationError({required this.errors});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    final errors = <String, List<String>>{};
    json.forEach((key, value) {
      errors[key] = List<String>.from(value);
    });

    return ValidationError(
      errors: errors,
    );
  }
}
