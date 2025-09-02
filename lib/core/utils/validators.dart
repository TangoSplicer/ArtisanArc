class Validators {
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Price is optional
    }
    
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    
    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  static String? validateProjectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Project name must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Project name must be less than 100 characters';
    }
    
    return null;
  }

  static String? validateItemName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Item name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Item name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'Item name must be less than 50 characters';
    }
    
    return null;
  }
}