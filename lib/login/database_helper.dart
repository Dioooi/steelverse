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
      version: 3, // Increment version
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE,
        password TEXT NOT NULL,
        is_blocked INTEGER DEFAULT 0
      )
    ''');

    // Cart items table
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

    // NEW: Purchase history table
    await db.execute('''
      CREATE TABLE purchase_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        order_id TEXT NOT NULL UNIQUE,
        product_ids TEXT NOT NULL,  -- Store as JSON array or comma-separated
        product_names TEXT NOT NULL, -- Store as JSON array or comma-separated
        total_amount REAL NOT NULL,
        original_amount REAL NOT NULL,
        savings REAL NOT NULL,
        items_count INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        purchase_date TEXT NOT NULL, -- ISO 8601 format
        status TEXT DEFAULT 'completed' -- completed, pending, cancelled
      )
    ''');

    // NEW: Index for faster queries
    await db.execute('''
      CREATE INDEX idx_purchase_history_username ON purchase_history(username)
    ''');
    await db.execute('''
      CREATE INDEX idx_purchase_history_date ON purchase_history(purchase_date)
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

    // Add purchase history table in version 3
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchase_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          order_id TEXT NOT NULL UNIQUE,
          product_ids TEXT NOT NULL,
          product_names TEXT NOT NULL,
          total_amount REAL NOT NULL,
          original_amount REAL NOT NULL,
          savings REAL NOT NULL,
          items_count INTEGER NOT NULL,
          payment_method TEXT NOT NULL,
          purchase_date TEXT NOT NULL,
          status TEXT DEFAULT 'completed'
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_purchase_history_username ON purchase_history(username)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_purchase_history_date ON purchase_history(purchase_date)
      ''');
    }
  }

  // --- Cart Database Methods --- (keep existing)

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

    batch.delete(
      'cart_items',
      where: 'username = ?',
      whereArgs: [username],
    );

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

  // --- NEW: Purchase History Methods ---

  /// Save a purchase record
  Future<int> savePurchase({
    required String username,
    required String orderId,
    required List<String> productIds,
    required List<String> productNames,
    required double totalAmount,
    required double originalAmount,
    required double savings,
    required int itemsCount,
    required String paymentMethod,
    required DateTime purchaseDate,
    String status = 'completed',
  }) async {
    final db = await instance.database;

    return await db.insert('purchase_history', {
      'username': username,
      'order_id': orderId,
      'product_ids': productIds.join(','), // Store as comma-separated string
      'product_names': productNames.join(','),
      'total_amount': totalAmount,
      'original_amount': originalAmount,
      'savings': savings,
      'items_count': itemsCount,
      'payment_method': paymentMethod,
      'purchase_date': purchaseDate.toIso8601String(),
      'status': status,
    });
  }

  /// Get purchase history for a specific user
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String username) async {
    final db = await instance.database;
    final results = await db.query(
      'purchase_history',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'purchase_date DESC',
    );
    return results;
  }

  /// Get all purchase history (for admin)
  Future<List<Map<String, dynamic>>> getAllPurchaseHistory() async {
    final db = await instance.database;
    final results = await db.query(
      'purchase_history',
      orderBy: 'purchase_date DESC',
    );
    return results;
  }

  /// Get purchase by order ID
  Future<Map<String, dynamic>?> getPurchaseByOrderId(String orderId) async {
    final db = await instance.database;
    final results = await db.query(
      'purchase_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update purchase status
  Future<int> updatePurchaseStatus(String orderId, String status) async {
    final db = await instance.database;
    return await db.update(
      'purchase_history',
      {'status': status},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  /// Delete a purchase record
  Future<int> deletePurchase(String orderId) async {
    final db = await instance.database;
    return await db.delete(
      'purchase_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  /// Clear all purchase history for a user
  Future<int> clearUserPurchaseHistory(String username) async {
    final db = await instance.database;
    return await db.delete(
      'purchase_history',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // --- Existing User Management Methods --- (keep all your existing methods)

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