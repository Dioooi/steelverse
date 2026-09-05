import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

/// Wraps all direct SQLite access for products behind one small API, so
/// ProductStore doesn't need to know or care that the data lives in
/// sqflite specifically. Follows the same singleton + database service
/// pattern taught in Practical 9 (SQLite).
class ProductRepository {
  static final ProductRepository _productRepository = ProductRepository._internal();
  factory ProductRepository() => _productRepository;
  ProductRepository._internal();

  static const String _tableName = 'products';
  static Database? _database;

  /// Get an instance of database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize a database
  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    final path = join(getDirectory.path, 'steelverse.db');
    return openDatabase(path, onCreate: _onCreate, version: 1);
  }

  /// Create the table
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
  }

  /// SQLite columns are plain scalar types, so galleryImageUrls (a List)
  /// gets JSON-encoded into a single TEXT column here, and decoded back
  /// out in [_fromRow]. Favorite status isn't stored at all -- it stays
  /// local/session-only.
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

  /// Only writes the seed list if the table is currently empty, so this is
  /// safe to call every time the app starts without duplicating data or
  /// wiping out anything an admin has already added or edited.
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
}