class UserStorage {
  // Sample default users
  static final Map<String, String> _users = {
    'suthan@gmail.com': 'suthan123',
    'yassa@gmail.com': 'yassa123',
    'abu@gmail.com': 'abu123',
  };

  // Add new user
  static void addUser(String email, String password) {
    _users[email.trim()] = password.trim();
  }

  // Check login credentials
  static bool validateUser(String email, String password) {
    return _users[email.trim()] == password.trim();
  }

  // Check if user already exists
  static bool exists(String email) {
    return _users.containsKey(email.trim());
  }

  // Get all users (optional)
  static Map<String, String> get users => _users;
}
