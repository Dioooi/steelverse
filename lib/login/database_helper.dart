import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE,
        password TEXT NOT NULL,
        is_blocked INTEGER DEFAULT 0
      )
    ''');
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: '(username = ? OR email = ?) AND password = ?',
      whereArgs: [username, username, password],
    );

    if (results.isNotEmpty) {
      final user = Map<String, dynamic>.from(results.first);
      user['name'] = user['username'];
      return user;
    }
    return null;
  }

  Future<int> registerUser({
    required String name,
    String? email,
    required String password,
  }) async {
    final db = await instance.database;

    final existing = await db.query(
      'users',
      where: 'username = ? OR (email IS NOT NULL AND email = ? AND email != "")',
      whereArgs: [name, email ?? name],
    );

    if (existing.isNotEmpty) {
      return -1;
    }

    return await db.insert('users', {
      'username': name,
      'email': email ?? name,
      'password': password,
      'is_blocked': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    final users = await db.query(
      'users',
      where: 'LOWER(username) != ?',
      whereArgs: ['admin'],
    );

    return users.map((u) {
      final map = Map<String, dynamic>.from(u);
      map['name'] = map['username'];
      return map;
    }).toList();
  }

  Future<int> updateUserBlockStatus(int id, int isBlocked) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'is_blocked': isBlocked},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleBlockUser(dynamic identifier, bool block) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'is_blocked': block ? 1 : 0},
      where: 'id = ? OR username = ?',
      whereArgs: [identifier, identifier],
    );
  }

  Future<int> deleteUser(dynamic identifier) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ? OR username = ?',
      whereArgs: [identifier, identifier],
    );
  }

  Future<int> deleteUserById(dynamic id) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ? OR username = ?',
      whereArgs: [id, id],
    );
  }
}