import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/MenuSection.dart';
import 'package:saba2v2/models/MenuItem.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/providers/menu_management_provider.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  int? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    // تأخير بسيط لضمان أن الـ Providers متاحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final restaurantId = authProvider.realEstateId; // نفترض أن هذا هو ID المطعم

    if (restaurantId != null) {
      final menuProvider = Provider.of<MenuManagementProvider>(context, listen: false);
      menuProvider.fetchMenu(restaurantId).then((_) {
        if (mounted && menuProvider.sections.isNotEmpty) {
          setState(() {
            _selectedSectionId = menuProvider.sections.first.id;
          });
        }
      });
    } else {
      // التعامل مع حالة عدم وجود ID للمطعم
      debugPrint("Restaurant ID not found, cannot fetch menu.");
    }
  }

  // --- نافذة إضافة قسم جديد ---
  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    final menuProvider = Provider.of<MenuManagementProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إضافة قسم جديد'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'مثال: الحلويات'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final categoryName = controller.text.trim();
              if (categoryName.isNotEmpty && authProvider.realEstateId != null) {
                final success = await menuProvider.addSection(
                  restaurantId: authProvider.realEstateId!,
                  title: categoryName,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'تم إضافة القسم بنجاح' : menuProvider.error ?? 'فشل إضافة القسم'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                }
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // --- نافذة إدارة الأقسام ---
  void _showManageCategoriesDialog(BuildContext context, List<MenuSection> sections) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إدارة الأقسام'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sections.length,
            itemBuilder: (context, idx) {
              final section = sections[idx];
              final isRemovable = section.items.isEmpty;
              return ListTile(
                title: Text(section.title),
                trailing: isRemovable
                    ? IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                           final menuProvider = Provider.of<MenuManagementProvider>(context, listen: false);
                           await menuProvider.deleteSection(sectionId: section.id);
                           if (dialogContext.mounted) Navigator.pop(dialogContext);
                        },
                      )
                    : null,
                subtitle: !isRemovable ? Text('يحتوي على وجبات', style: TextStyle(color: Colors.grey, fontSize: 12)) : null,
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('إغلاق'))],
      ),
    );
  }

  // --- نافذة إضافة وجبة جديدة ---
  void _showAddMealDialog(BuildContext context, List<MenuSection> sections) {
    if (sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب إضافة قسم أولاً')));
      return;
    }
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    File? pickedImage;
    int? selectedSectionIdForDialog = _selectedSectionId ?? sections.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('إضافة وجبة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                    if (image != null) {
                      setStateDialog(() => pickedImage = File(image.path));
                    }
                  },
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(8)),
                    child: pickedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(7), child: Image.file(pickedImage!, fit: BoxFit.cover))
                        : Center(child: Icon(Icons.add_a_photo, color: Colors.grey)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'اسم الوجبة')),
                SizedBox(height: 8),
                TextField(controller: descController, decoration: InputDecoration(labelText: 'الوصف')),
                SizedBox(height: 8),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
                SizedBox(height: 8),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedSectionIdForDialog,
                  items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.title))).toList(),
                  onChanged: (value) {
                    if (value != null) setStateDialog(() => selectedSectionIdForDialog = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (pickedImage == null || nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء كل الحقول واختيار صورة'), backgroundColor: Colors.red));
                  return;
                }
                final menuProvider = Provider.of<MenuManagementProvider>(context, listen: false);
                final success = await menuProvider.addMenuItem(
                  sectionId: selectedSectionIdForDialog!,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  price: double.tryParse(priceController.text.trim()) ?? 0.0,
                  imageFile: pickedImage!,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'تم إضافة الوجبة بنجاح' : menuProvider.error ?? 'فشل إضافة الوجبة'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                }
              },
              child: Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuManagementProvider>(
      builder: (context, menuProvider, child) {
        MenuSection? selectedSection;
        if (_selectedSectionId != null && menuProvider.sections.isNotEmpty) {
          try {
            selectedSection = menuProvider.sections.firstWhere((s) => s.id == _selectedSectionId);
          } catch (e) {
            _selectedSectionId = menuProvider.sections.first.id;
            selectedSection = menuProvider.sections.first;
          }
        }
        final filteredMeals = selectedSection?.items ?? [];

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text("إدارة القائمة"),
              actions: [
                IconButton(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: Icon(Icons.add_box_outlined, color: Colors.orange),
                  tooltip: 'إضافة قسم',
                ),
                IconButton(
                  onPressed: () => _showManageCategoriesDialog(context, menuProvider.sections),
                  icon: Icon(Icons.list_alt, color: Colors.orange),
                  tooltip: 'إدارة الأقسام',
                ),
              ],
            ),
            body: menuProvider.isLoading && menuProvider.sections.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (menuProvider.sections.isNotEmpty)
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: menuProvider.sections.length,
                            itemBuilder: (context, index) {
                              final section = menuProvider.sections[index];
                              final isSelected = section.id == _selectedSectionId;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedSectionId = section.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.orange : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
                                  ),
                                  child: Center(child: Text(section.title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                                ),
                              );
                            },
                          ),
                        ),
                      Expanded(
                        child: filteredMeals.isEmpty
                            ? Center(
                                child: Text(
                                  menuProvider.sections.isEmpty
                                  ? 'قم بإضافة قسم جديد للبدء'
                                  : 'لا توجد وجبات في هذا القسم',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: filteredMeals.length,
                                itemBuilder: (context, idx) {
                                  final meal = filteredMeals[idx];
                                  return _buildMealCard(meal);
                                },
                              ),
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddMealDialog(context, menuProvider.sections),
              label: const Text("إضافة وجبة"),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.orange,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealCard(MenuItem meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: meal.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
        title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(meal.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        trailing: Text("${meal.price.toStringAsFixed(0)} ج.م", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15)),
        onTap: () {
          // TODO: Implement meal details/edit dialog
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تفاصيل الوجبة: ${meal.name}')));
        },
      ),
    );
  }
}