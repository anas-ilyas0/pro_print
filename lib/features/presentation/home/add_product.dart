import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proprint/core/providers/product_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddProduct extends StatefulWidget {
  final Product? product;
  const AddProduct({super.key, this.product});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _prodDescController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _prodDescController.dispose();
    super.dispose();
  }

  File? _pickedImage;
  String? _existingImageUrl;

  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoading = false;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final existingCategory = args?['category'];

      _loadCategories(existingCategory: existingCategory);

      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _quantityController.text = widget.product!.quantity.toString();
      _priceController.text = widget.product!.price.toString();
      _prodDescController.text = widget.product!.prodDesc;
      _selectedCategory = widget.product!.category;
      _existingImageUrl = widget.product!.imageUrl;
    }
  }

  Future<void> _loadCategories({String? existingCategory}) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) throw Exception("User not logged in");

      final response = await supabase
          .from('categories')
          .select('name')
          .eq('user_id', userId);
      //final response = await supabase.from('categories').select('name');
      final names = (response as List).map((e) => e['name'] as String).toList();
      setState(() {
        _categories = names;
        // Check if existingCategory is still available, else set to null
        if (existingCategory != null && names.contains(existingCategory)) {
          _selectedCategory = existingCategory;
        } else {
          _selectedCategory = null; // Prompt user to choose
        }
      });
    } catch (e) {
      print("Error loading categories: $e");
      if (mounted) {
        Widgets.customSnackbar(
            context, AppColors.red, 'Failed to load categories');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.white),
                title: Text('Take Photo',
                    style:
                        AppTextStyle(fontSize: 14.sp, color: AppColors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final picked =
                      await picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() => _pickedImage = File(picked.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.white),
                title: Text('Choose from Gallery',
                    style:
                        AppTextStyle(fontSize: 14.sp, color: AppColors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final picked =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _pickedImage = File(picked.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() async {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();
    final price = _priceController.text.trim();
    final prodDesc = _prodDescController.text.trim();

    if (_formKey.currentState!.validate()) {
      if (_pickedImage == null) {
        Widgets.customSnackbar(context, AppColors.red, 'Please pick an image');
        return;
      }

      setState(() => _isLoading = true);

      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        if (user == null) throw Exception("User not logged in");

        // Generate unique file name
        final fileExt = _pickedImage!.path.split('.').last;
        final fileName = "${const Uuid().v4()}.$fileExt";

        // Upload to storage
        final storageResponse = await supabase.storage
            .from('product-images/products')
            .upload('products/$fileName', _pickedImage!);
        if (storageResponse.isEmpty) {
          throw Exception("Image upload failed");
        }

        // Get public URL
        final imageUrl = supabase.storage
            .from('product-images/products')
            .getPublicUrl('products/$fileName');

        // Insert into Supabase table
        if (widget.product == null) {
          await supabase.from('products').insert({
            'name': name,
            'image_url': imageUrl,
            'category': _selectedCategory,
            'quantity': int.parse(quantity),
            'price': double.parse(price),
            'prodDesc': prodDesc,
            'created_at': DateTime.now().toIso8601String(),
            'user_id': user.id,
          });
          if (mounted) {
            Widgets.customSnackbar(context, AppColors.blueGrey,
                "Product '$name' added successfully!");
            Navigator.pop(context);
          }
        } else {
          await supabase.from('products').update({
            'name': name,
            'image_url': imageUrl,
            'category': _selectedCategory,
            'quantity': int.parse(quantity),
            'price': double.parse(price),
            'prodDesc': prodDesc,
          }).eq('id', widget.product!.id);
          if (mounted) {
            Widgets.customSnackbar(context, AppColors.blueGrey,
                "Product '$name' added successfully!");
            Navigator.pop(context);
          }
        }

        _nameController.clear();
        setState(() {
          _pickedImage = null;
        });
      } catch (e) {
        print(e);
        if (mounted) {
          Widgets.customSnackbar(context, AppColors.red, e.toString());
        }
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      Widgets.customSnackbar(
          context, AppColors.red, 'Please fill out all required data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.blueGrey.withValues(alpha: 0.6),
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_existingImageUrl != null
                            ? NetworkImage(_existingImageUrl!) as ImageProvider
                            : null),
                    child: _pickedImage == null
                        ? const Icon(Icons.add_photo_alternate,
                            color: Colors.white, size: 30)
                        : null,
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: AppTextStyle(fontSize: 12.sp),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 15.h),
                DropdownButtonFormField<String>(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.white,
                  ),
                  dropdownColor: AppColors.scaffoldBackgroundColor,
                  value: (_selectedCategory != null &&
                          _categories.contains(_selectedCategory))
                      ? _selectedCategory
                      : null,
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Select Category',
                        style: AppTextStyle(fontSize: 14.sp),
                      ),
                    ),
                    ..._categories.map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat.trim(),
                        child: Text(cat, style: AppTextStyle(fontSize: 14.sp)),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    labelStyle: AppTextStyle(fontSize: 14.sp),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select category' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 15.h),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: AppTextStyle(fontSize: 12.sp),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 15.h),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: AppTextStyle(fontSize: 12.sp),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 15.h),
                TextFormField(
                  controller: _prodDescController,
                  maxLines: 4,
                  style: AppTextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Product Description',
                    labelStyle: AppTextStyle(fontSize: 12.sp),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 25.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueGrey.withValues(alpha: 0.6),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                  ),
                  onPressed: _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          widget.product == null
                              ? 'Add Product'
                              : 'Update Product',
                          style: AppTextStyle(
                              fontSize: 16.sp, color: AppColors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
