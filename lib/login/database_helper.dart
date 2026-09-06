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
      version: 7,
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
        pin TEXT DEFAULT '123456',
        is_blocked INTEGER DEFAULT 0,
        address TEXT DEFAULT '',
        phone TEXT DEFAULT '',
        balance REAL DEFAULT 5.0
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

    await db.execute('''
      CREATE TABLE purchase_history (
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
      CREATE TABLE credit_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        card_number TEXT NOT NULL,
        card_holder_name TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        cvv TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_purchase_history_username ON purchase_history(username)
    ''');
    await db.execute('''
      CREATE INDEX idx_purchase_history_date ON purchase_history(purchase_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_credit_cards_username ON credit_cards(username)
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

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS credit_cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          card_number TEXT NOT NULL,
          card_holder_name TEXT NOT NULL,
          expiry_date TEXT NOT NULL,
          cvv TEXT NOT NULL,
          is_default INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (username) REFERENCES users(username)
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_credit_cards_username ON credit_cards(username)
      ''');
    }

    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN address TEXT DEFAULT ""');
      } catch (e) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT DEFAULT ""');
      } catch (e) {}
    }

    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN balance REAL DEFAULT 5.0');
      } catch (e) {}
    }

    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN pin TEXT DEFAULT "123456"');
      } catch (e) {}
    }
  }

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
      'product_ids': productIds.join(','),
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

  Future<List<Map<String, dynamic>>> getAllPurchaseHistory() async {
    final db = await instance.database;
    final results = await db.query(
      'purchase_history',
      orderBy: 'purchase_date DESC',
    );
    return results;
  }

  Future<Map<String, dynamic>?> getPurchaseByOrderId(String orderId) async {
    final db = await instance.database;
    final results = await db.query(
      'purchase_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updatePurchaseStatus(String orderId, String status) async {
    final db = await instance.database;
    return await db.update(
      'purchase_history',
      {'status': status},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> deletePurchase(String orderId) async {
    final db = await instance.database;
    return await db.delete(
      'purchase_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> clearUserPurchaseHistory(String username) async {
    final db = await instance.database;
    return await db.delete(
      'purchase_history',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> saveCreditCard({
    required String username,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
    bool isDefault = false,
  }) async {
    final db = await instance.database;

    if (isDefault) {
      await db.update(
        'credit_cards',
        {'is_default': 0},
        where: 'username = ?',
        whereArgs: [username],
      );
    }

    return await db.insert('credit_cards', {
      'username': username,
      'card_number': cardNumber,
      'card_holder_name': cardHolderName,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'is_default': isDefault ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCreditCards(String username) async {
    final db = await instance.database;
    final results = await db.query(
      'credit_cards',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'is_default DESC, created_at DESC',
    );
    return results;
  }

  Future<Map<String, dynamic>?> getDefaultCreditCard(String username) async {
    final db = await instance.database;
    final results = await db.query(
      'credit_cards',
      where: 'username = ? AND is_default = 1',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteCreditCard(int cardId) async {
    final db = await instance.database;
    return await db.delete(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<int> setDefaultCreditCard(String username, int cardId) async {
    final db = await instance.database;

    await db.update(
      'credit_cards',
      {'is_default': 0},
      where: 'username = ?',
      whereArgs: [username],
    );

    return await db.update(
      'credit_cards',
      {'is_default': 1},
      where: 'id = ? AND username = ?',
      whereArgs: [cardId, username],
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUserAddress(String username, String address) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'address': address},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> updateUserPhone(String username, String phone) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'phone': phone},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> updateUserInfo(String username, String address, String phone) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'address': address, 'phone': phone},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> updateUserBalance(String username, double balance) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'balance': balance},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> updateUserPin(String username, String pin) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'pin': pin},
      where: 'username = ?',
      whereArgs: [username],
    );
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
      'pin': '123456',
      'is_blocked': 0,
      'address': '',
      'phone': '',
      'balance': 5.0,
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

  Future<int> updateUserCredentials(String oldUsername, String newUsername, String? newPassword) async {
    final db = await instance.database;
    final values = <String, dynamic>{'username': newUsername};
    if (newPassword != null && newPassword.isNotEmpty) {
      values['password'] = newPassword;
    }
    return await db.update(
      'users',
      values,
      where: 'username = ?',
      whereArgs: [oldUsername],
    );
  }

  Future<int> updateUserCredentialsById(dynamic id, String newUsername, String? newPassword) async {
    final db = await instance.database;
    final values = <String, dynamic>{'username': newUsername};
    if (newPassword != null && newPassword.isNotEmpty) {
      values['password'] = newPassword;
    }
    return await db.update(
      'users',
      values,
      where: 'id = ? OR username = ?',
      whereArgs: [id, id],
    );
  }
}