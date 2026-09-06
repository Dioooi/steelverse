// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_price REAL NOT NULL,
        product_category TEXT NOT NULL,
        product_image_url TEXT,
        quantity INTEGER NOT NULL,
        selected INTEGER NOT NULL DEFAULT 1,
        UNIQUE(username, product_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cart_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          product_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          product_price REAL NOT NULL,
          product_category TEXT NOT NULL,
          product_image_url TEXT,
          quantity INTEGER NOT NULL,
          selected INTEGER NOT NULL DEFAULT 1,
          UNIQUE(username, product_id)
        )
      ''');
    }
  }

  // --- Cart Database Methods ---

  Future<List<CartItem>> getCartForUser(String username) async {
    final db = await instance.database;
    final results = await db.query(
      'cart_items',
      where: 'username = ?',
      whereArgs: [username],
    );

    return results.map((row) {
      final product = Product(
        id: row['product_id'] as String,
        name: row['product_name'] as String,
        price: (row['product_price'] as num).toDouble(),
        category: row['product_category'] as String,
        imageUrl: row['product_image_url'] as String?,
      );

      return CartItem(
        product: product,
        quantity: row['quantity'] as int,
        selected: (row['selected'] as int) == 1,
      );
    }).toList();
  }

  Future<void> saveUserCart(String username, List<CartItem> items) async {
    final db = await instance.database;
    final batch = db.batch();

    // Clear old cart entries for the specific user
    batch.delete(
      'cart_items',
      where: 'username = ?',
      whereArgs: [username],
    );

    // Insert updated list of cart items
    for (final item in items) {
      batch.insert('cart_items', {
        'username': username,
        'product_id': item.product.id,
        'product_name': item.product.name,
        'product_price': item.product.price,
        'product_category': item.product.category,
        'product_image_url': item.product.imageUrl,
        'quantity': item.quantity,
        'selected': item.selected ? 1 : 0,
      });
    }

    await batch.commit(noResult: true);
  }

  // Existing user management methods...
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