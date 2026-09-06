import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../state/product_store.dart';
import '../widgets/product_image.dart';
import 'user_management_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    ProductStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    ProductStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> _pickAndSaveImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white70),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Colors.white70),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile == null) return null;

    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docsDir.path, 'product_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(pickedFile.path);
    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedPath = p.join(imagesDir.path, fileName);

    final bytes = await pickedFile.readAsBytes();
    await File(savedPath).writeAsBytes(bytes);

    return savedPath;
  }

  void _confirmDelete(BuildContext context, String productId, String productName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24),
          ),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Are you sure you want to delete "$productName"? This action cannot be undone.',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await ProductStore.instance.deleteProduct(productId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$productName" deleted successfully')),
        );
      }
    }
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toStringAsFixed(2));
    final promoPriceController = TextEditingController(
      text: product.promoPrice != null ? product.promoPrice!.toStringAsFixed(2) : '',
    );
    final categoryController = TextEditingController(text: product.category);
    final descriptionController = TextEditingController(text: product.description);
    final imageUrlController = TextEditingController(text: product.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24),
          ),
          title: const Text('Edit Product', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ProductImage(
                      imageUrl: imageUrlController.text.isEmpty ? null : imageUrlController.text,
                      assetPath: product.imageAsset,
                      width: 88,
                      height: 88,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final savedPath = await _pickAndSaveImage(dialogContext);
                      if (savedPath != null) {
                        imageUrlController.text = savedPath;
                        setDialogState(() {});
                      }
                    },
                    icon: const Icon(Icons.add_a_photo_outlined, color: Colors.orangeAccent, size: 18),
                    label: const Text('Choose Photo', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Price (RM)',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: promoPriceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Promotion Price (RM) - optional',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Leave blank for no promotion',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  TextField(
                    controller: categoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: imageUrlController,
                    onChanged: (_) => setDialogState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Image URL (or use Choose Photo above)',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'https://... or leave blank',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? product.price;
                final category = categoryController.text.trim();
                final description = descriptionController.text.trim();
                final imageUrl = imageUrlController.text.trim();

                final promoPriceText = promoPriceController.text.trim();
                double? promoPrice;
                bool clearPromo = false;
                if (promoPriceText.isEmpty) {
                  clearPromo = true;
                } else {
                  promoPrice = double.tryParse(promoPriceText);
                  if (promoPrice == null || promoPrice <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Enter a valid promotion price, or leave it blank.')),
                    );
                    return;
                  }
                  if (promoPrice >= price) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Promotion price must be lower than the regular price.')),
                    );
                    return;
                  }
                }

                if (name.isNotEmpty && price > 0) {
                  final updatedProduct = product.copyWith(
                    name: name,
                    description: description.isEmpty ? null : description,
                    price: price,
                    promoPrice: promoPrice,
                    clearPromo: clearPromo,
                    category: category.isEmpty ? null : category,
                    imageUrl: imageUrl.isEmpty ? null : imageUrl,
                  );

                  Navigator.pop(dialogContext);
                  await ProductStore.instance.updateProduct(updatedProduct);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated "$name" successfully')),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final promoPriceController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24),
          ),
          title: const Text('Add New Product', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ProductImage(
                      imageUrl: imageUrlController.text.isEmpty ? null : imageUrlController.text,
                      width: 88,
                      height: 88,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final savedPath = await _pickAndSaveImage(dialogContext);
                      if (savedPath != null) {
                        imageUrlController.text = savedPath;
                        setDialogState(() {});
                      }
                    },
                    icon: const Icon(Icons.add_a_photo_outlined, color: Colors.orangeAccent, size: 18),
                    label: const Text('Choose Photo', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Price (RM)',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: promoPriceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Promotion Price (RM) - optional',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Leave blank for no promotion',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  TextField(
                    controller: categoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: imageUrlController,
                    onChanged: (_) => setDialogState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Image URL (or use Choose Photo above)',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'https://... or leave blank',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;
                final category = categoryController.text.trim();
                final description = descriptionController.text.trim();
                final imageUrl = imageUrlController.text.trim();

                final promoPriceText = promoPriceController.text.trim();
                double? promoPrice;
                if (promoPriceText.isNotEmpty) {
                  promoPrice = double.tryParse(promoPriceText);
                  if (promoPrice == null || promoPrice <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Enter a valid promotion price, or leave it blank.')),
                    );
                    return;
                  }
                  if (promoPrice >= price) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Promotion price must be lower than the regular price.')),
                    );
                    return;
                  }
                }

                if (name.isNotEmpty && price > 0) {
                  final newProduct = Product(
                    id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    description: description.isEmpty ? 'Industrial grade tool component' : description,
                    price: price,
                    promoPrice: promoPrice,
                    category: category.isEmpty ? 'Hardware Parts' : category,
                    imageUrl: imageUrl.isEmpty ? null : imageUrl,
                  );

                  Navigator.pop(dialogContext);
                  await ProductStore.instance.addProduct(newProduct);
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ProductStore.instance.products;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Admin Inventory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.people_alt_outlined, color: Colors.orangeAccent),
                      tooltip: 'User Management',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserManagementPage()),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 22),
                      onPressed: () => _showAddProductDialog(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                  child: Text(
                    'No items in inventory',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final crossAxisCount = isMobile ? 2 : 3;

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: isMobile ? 0.78 : 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ProductImage(
                                      imageUrl: product.imageUrl,
                                      assetPath: product.imageAsset,
                                      width: double.infinity,
                                      height: double.infinity,
                                      borderRadius: BorderRadius.circular(6),
                                      placeholderIcon: Icons.build_rounded,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  product.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: product.hasPromo
                                          ? Row(
                                        children: [
                                          Text(
                                            'RM${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'RM${product.promoPrice!.toStringAsFixed(2)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.orangeAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          : Text(
                                        'RM${product.price.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showEditProductDialog(context, product),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blueAccent,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _confirmDelete(context, product.id, product.name),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}