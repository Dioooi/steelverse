import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('steelverse_hardware.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer'
      )
    ''');

    // Default Seed Admin
    await db.insert('users', {
      'id': 'admin_1',
      'name': 'Admin',
      'email': 'admin@hardware.com',
      'password': '123',
      'role': 'admin'
    });
  }

  // Register New User
  Future<int> registerUser({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
    final db = await instance.database;
    return await db.insert('users', {
      'id': 'u_${DateTime.now().millisecondsSinceEpoch}',
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
      'role': role,
    });
  }

  // Authenticate / Login User
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password.trim()],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> deleteUser(String username) async {
    final db = await instance.database;
    return await db.delete(
      'users', // Ensure this matches your database table name
      where: 'name = ?', // Change 'name' to 'email' or 'username' depending on your column name
      whereArgs: [username],
    );
  }
}