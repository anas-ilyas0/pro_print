import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proprint/core/providers/category_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddCategory extends StatefulWidget {
  final Category? category;
  const AddCategory({super.key, this.category});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _pickedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _existingImageUrl = widget.category!.imageUrl;
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
                    style: AppTextStyle(
                      fontSize: 14.sp,
                    )),
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
                    style: AppTextStyle(
                      fontSize: 14.sp,
                    )),
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
            .from('category-images/categories')
            .upload('categories/$fileName', _pickedImage!);

        if (storageResponse.isEmpty) {
          throw Exception("Image upload failed");
        }

        // Get public URL
        final imageUrl = supabase.storage
            .from('category-images/categories')
            .getPublicUrl('categories/$fileName');

        // Insert into Supabase table
        if (widget.category == null) {
          await supabase.from('categories').insert({
            'name': name,
            'image_url': imageUrl,
            'created_at': DateTime.now().toIso8601String(),
            'user_id': user.id,
          });
          if (mounted) {
            Widgets.customSnackbar(context, AppColors.blueGrey,
                "Category '$name' added successfully!");
            Navigator.pop(context);
          }
        } else {
          await supabase.from('categories').update({
            'name': name,
            'image_url': imageUrl,
          }).eq('id', widget.category!.id);
          if (mounted) {
            Widgets.customSnackbar(context, AppColors.blueGrey,
                "Category '$name' updated successfully!");
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
      appBar: AppBar(title: const Text('Add Category')),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
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
                      ? const Icon(Icons.add_a_photo,
                          color: AppColors.white, size: 30)
                      : null,
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _nameController,
                style: AppTextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: AppTextStyle(fontSize: 12.sp),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueGrey.withValues(alpha: 0.6)),
                onPressed: _submitForm,
                child: _isLoading
                    ? Padding(
                        padding: EdgeInsets.all(4.r),
                        child: const CircularProgressIndicator(
                            color: AppColors.white),
                      )
                    : Text(
                        widget.category == null
                            ? 'Add Category'
                            : 'Update Category',
                        style: AppTextStyle(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
