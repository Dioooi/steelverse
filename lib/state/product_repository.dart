import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

class ProductRepository {
  static final ProductRepository _productRepository = ProductRepository._internal();
  factory ProductRepository() => _productRepository;
  ProductRepository._internal();

  static const String _tableName = 'products';
  static const String _favoritesTableName = 'favorites';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    final path = join(getDirectory.path, 'steelverse.db');
    return openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 2,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        promoPrice REAL,
        rating REAL,
        reviewCount INTEGER,
        category TEXT,
        imageUrl TEXT,
        imageAsset TEXT,
        galleryImageUrls TEXT,
        stock INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE $_favoritesTableName (
        username TEXT NOT NULL,
        productId TEXT NOT NULL,
        PRIMARY KEY (username, productId)
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_favoritesTableName (
          username TEXT NOT NULL,
          productId TEXT NOT NULL,
          PRIMARY KEY (username, productId)
        )
      ''');
    }
  }

  Map<String, dynamic> _toRow(Product product) {
    final json = product.toJson();
    return {
      'id': json['id'],
      'name': json['name'],
      'description': json['description'],
      'price': json['price'],
      'promoPrice': json['promoPrice'],
      'rating': json['rating'],
      'reviewCount': json['reviewCount'],
      'category': json['category'],
      'imageUrl': json['imageUrl'],
      'imageAsset': json['imageAsset'],
      'galleryImageUrls': jsonEncode(json['galleryImageUrls'] ?? []),
      'stock': json['stock'],
    };
  }

  Product _fromRow(Map<String, dynamic> row) {
    final rawGallery = row['galleryImageUrls'] as String?;
    return Product.fromJson({
      ...row,
      'galleryImageUrls': (rawGallery != null && rawGallery.isNotEmpty)
          ? jsonDecode(rawGallery)
          : <String>[],
    });
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final rows = await db.query(_tableName);
    return rows.map(_fromRow).toList();
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert(
      _tableName,
      _toRow(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      _tableName,
      _toRow(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String productId) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> seedIfEmpty(List<Product> seedProducts) async {
    final db = await database;
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    if ((countResult ?? 0) > 0) return;
    final batch = db.batch();
    for (final product in seedProducts) {
      batch.insert(_tableName, _toRow(product));
    }
    await batch.commit(noResult: true);
  }

  Future<Set<String>> getFavoriteIds(String username) async {
    final db = await database;
    final rows = await db.query(
      _favoritesTableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    return rows.map((row) => row['productId'] as String).toSet();
  }

  Future<void> setFavorite(String username, String productId, bool isFavorite) async {
    final db = await database;
    if (isFavorite) {
      await db.insert(
        _favoritesTableName,
        {'username': username, 'productId': productId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        _favoritesTableName,
        where: 'username = ? AND productId = ?',
        whereArgs: [username, productId],
      );
    }
  }
}