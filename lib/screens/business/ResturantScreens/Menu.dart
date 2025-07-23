import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MealModel {
  String image;
  String name;
  String description;
  double price;
  String category;

  MealModel({
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
  });
}

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final List<String> _categories = [
    "البيتزا",
    "السندوتشات",
    "المشويات",
    "المقبلات",
    "المشروبات",
  ];

  String _selectedCategory = "البيتزا";

  final List<MealModel> _meals = [
    MealModel(
      image: 'assets/images/pizza.jpg',
      name: 'بيتزا دجاج',
      description: 'بيتزا دجاج مع صوص المطاعم والفلفل الحلو. مع إضافة رانش صوص',
      price: 200,
      category: "البيتزا",
    ),
    MealModel(
      image: 'assets/images/pizza.jpg',
      name: 'بيتزا لحوم',
      description: 'بيتزا باللحم المفروم والزيتون الأسود وجبنة موتزاريلا',
      price: 220,
      category: "البيتزا",
    ),
    MealModel(
      image: 'assets/images/grill.jpg',
      name: 'مشاوي مشكلة',
      description: 'تشكيلة مشاوي مع أرز وسلطة طازجة',
      price: 250,
      category: "المشويات",
    ),
    MealModel(
      image: 'assets/images/burger.jpg',
      name: 'برجر دجاج',
      description: 'برجر دجاج مع بطاطس مقلية وصلصة خاصة',
      price: 180,
      category: "السندوتشات",
    ),
  ];

  void _showAddCategoryDialog(BuildContext context, double screenWidth) {
    String? categoryName;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: screenWidth * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إضافة قسم جديد',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'اسم القسم',
                    hintText: 'مثال: الحلويات',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  onChanged: (value) => categoryName = value.trim(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (categoryName != null && categoryName!.isNotEmpty) {
                            if (!_categories.contains(categoryName)) {
                              setState(() {
                                _categories.add(categoryName!);
                                _selectedCategory = categoryName!;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم إضافة القسم "$categoryName" بنجاح', style: TextStyle(fontSize: screenWidth * 0.04)),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  margin: EdgeInsets.all(screenWidth * 0.02),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('هذا القسم موجود بالفعل', style: TextStyle(fontSize: screenWidth * 0.04)),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  margin: EdgeInsets.all(screenWidth * 0.02),
                                ),
                              );
                            }
                          }
                        },
                        child: Text('إضافة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext context, double screenWidth) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('إدارة الأقسام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
          content: SizedBox(
            width: screenWidth * 0.7,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final isRemovable = _meals.where((m) => m.category == _categories[idx]).isEmpty;
                return ListTile(
                  title: Text(_categories[idx]),
                  trailing: isRemovable
                      ? IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('تأكيد الحذف'),
                          content: Text('هل تريد حذف القسم؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _categories.removeAt(idx));
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('حذف'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                      : null,
                  subtitle: !isRemovable
                      ? Text('يحتوي على وجبات ولا يمكن حذفه', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.033))
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, double screenWidth) {
    String? name, description, category, imagePath;
    double? price;
    category = _selectedCategory;
    bool isCreatingNewCategory = false;
    String? newCategoryName;

    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SizedBox(
              width: screenWidth * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'إضافة وجبة جديدة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    GestureDetector(
                      onTap: () {
                        imagePath = 'assets/images/pizza.jpg';
                        setStateDialog(() {});
                      },
                      child: Container(
                        height: screenWidth * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 2),
                          image: imagePath != null ? DecorationImage(image: AssetImage(imagePath!), fit: BoxFit.cover) : null,
                        ),
                        child: imagePath == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.orange, size: screenWidth * 0.08),
                            SizedBox(height: screenWidth * 0.02),
                            Text(
                              'اضغط لإضافة صورة',
                              style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                            : null,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الوجبة',
                        hintText: 'مثال: بيتزا مارجريتا',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      onChanged: (value) => name = value,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'الوصف',
                        hintText: 'وصف مفصل عن الوجبة...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) => description = value,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'السعر (جنيه)',
                        hintText: '100',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => price = double.tryParse(value),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, textAlign: TextAlign.right, style: TextStyle(fontSize: screenWidth * 0.04)))).toList(),
                            decoration: InputDecoration(
                              labelText: 'القسم',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                category = value;
                                setStateDialog(() {});
                              }
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        TextButton.icon(
                          onPressed: () {
                            isCreatingNewCategory = !isCreatingNewCategory;
                            setStateDialog(() {});
                          },
                          icon: Icon(isCreatingNewCategory ? Icons.close : Icons.add, color: Colors.orange, size: screenWidth * 0.05),
                          label: Text(
                            isCreatingNewCategory ? 'إلغاء' : 'جديد',
                            style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.orange)),
                          ),
                        ),
                      ],
                    ),
                    if (isCreatingNewCategory) ...[
                      SizedBox(height: screenWidth * 0.03),
                      TextField(
                        controller: newCategoryController,
                        decoration: InputDecoration(
                          labelText: 'اسم القسم الجديد',
                          hintText: 'مثال: الحلويات',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                        onChanged: (value) => newCategoryName = value.trim(),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (name != null && name!.isNotEmpty && description != null && description!.isNotEmpty && price != null && price! > 0 && imagePath != null) {
                    String finalCategory = category!;
                    if (isCreatingNewCategory && newCategoryName != null && newCategoryName!.isNotEmpty) {
                      if (!_categories.contains(newCategoryName)) {
                        _categories.add(newCategoryName!);
                        finalCategory = newCategoryName!;
                      }
                    }
                    setState(() {
                      _meals.add(MealModel(
                        image: imagePath!,
                        name: name!,
                        description: description!,
                        price: price!,
                        category: finalCategory,
                      ));
                      _selectedCategory = finalCategory;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إضافة الوجبة "$name" بنجاح', style: TextStyle(fontSize: screenWidth * 0.04)),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin: EdgeInsets.all(screenWidth * 0.02),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يرجى ملء جميع البيانات المطلوبة', style: TextStyle(fontSize: screenWidth * 0.04)),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin: EdgeInsets.all(screenWidth * 0.02),
                      ),
                    );
                  }
                },
                child: Text('إضافة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMealDetailsDialog(MealModel meal, BuildContext context, double screenWidth) {
    bool isEditing = false;
    String name = meal.name;
    String description = meal.description;
    double price = meal.price;
    String category = meal.category;
    String imagePath = meal.image;
    bool isCreatingNewCategory = false;
    String? newCategoryName;
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: description);
    final priceController = TextEditingController(text: price.toString());
    final newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SizedBox(
              width: screenWidth * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.02),
                        Text('تفاصيل الوجبة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
                        const Spacer(),
                        if (!isEditing)
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange, size: screenWidth * 0.05),
                            tooltip: "تعديل",
                            onPressed: () => setStateDialog(() => isEditing = true),
                          ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    GestureDetector(
                      onTap: isEditing
                          ? () {
                        imagePath = 'assets/images/burger.jpg';
                        setStateDialog(() {});
                      }
                          : null,
                      child: Container(
                        height: screenWidth * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 2),
                          image: imagePath != null ? DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover) : null,
                        ),
                        child: imagePath == null
                            ? Center(
                          child: Icon(Icons.camera_alt, color: Colors.orange, size: screenWidth * 0.08),
                        )
                            : null,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    TextField(
                      controller: nameController,
                      readOnly: !isEditing,
                      decoration: InputDecoration(
                        labelText: 'اسم الوجبة',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      onChanged: (value) => name = value,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    TextField(
                      controller: descController,
                      readOnly: !isEditing,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'الوصف',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) => description = value,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    TextField(
                      controller: priceController,
                      readOnly: !isEditing,
                      decoration: InputDecoration(
                        labelText: 'السعر (جنيه)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => price = double.tryParse(value) ?? 0,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    if (!isEditing)
                      DropdownButtonFormField<String>(
                        value: category,
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, textAlign: TextAlign.right, style: TextStyle(fontSize: screenWidth * 0.04)))).toList(),
                        decoration: InputDecoration(
                          labelText: 'القسم',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                        onChanged: null, // لا يسمح بالتعديل
                      ),
                    if (isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: category,
                              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, textAlign: TextAlign.right, style: TextStyle(fontSize: screenWidth * 0.04)))).toList(),
                              decoration: InputDecoration(
                                labelText: 'القسم',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                if (value != null) category = value;
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          TextButton.icon(
                            onPressed: () {
                              isCreatingNewCategory = !isCreatingNewCategory;
                              setStateDialog(() {});
                            },
                            icon: Icon(isCreatingNewCategory ? Icons.close : Icons.add, color: Colors.orange, size: screenWidth * 0.05),
                            label: Text(
                              isCreatingNewCategory ? 'إلغاء' : 'جديد',
                              style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035, fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.orange)),
                            ),
                          ),
                        ],
                      ),
                    if (isEditing && isCreatingNewCategory) ...[
                      SizedBox(height: screenWidth * 0.03),
                      TextField(
                        controller: newCategoryController,
                        decoration: InputDecoration(
                          labelText: 'اسم القسم الجديد',
                          hintText: 'مثال: الحلويات',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                        onChanged: (value) => newCategoryName = value.trim(),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إغلاق', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04)),
              ),
              if (isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      meal.name = name;
                      meal.description = description;
                      meal.price = price;
                      meal.image = imagePath;
                      String finalCategory = category;
                      if (isCreatingNewCategory && newCategoryName != null && newCategoryName!.isNotEmpty) {
                        if (!_categories.contains(newCategoryName)) {
                          _categories.add(newCategoryName!);
                          finalCategory = newCategoryName!;
                        }
                      }
                      meal.category = finalCategory;
                      _selectedCategory = finalCategory;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم حفظ التعديلات بنجاح', style: TextStyle(fontSize: screenWidth * 0.04)),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin: EdgeInsets.all(screenWidth * 0.02),
                      ),
                    );
                  },
                  child: Text('حفظ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                ),
              if (isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('تأكيد الحذف', style: TextStyle(fontSize: screenWidth * 0.045)),
                        content: Text('هل تريد حذف "${meal.name}" من القائمة؟', style: TextStyle(fontSize: screenWidth * 0.04)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('إلغاء', style: TextStyle(fontSize: screenWidth * 0.04)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() => _meals.remove(meal));
                              Navigator.pop(context);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم حذف "${meal.name}" بنجاح', style: TextStyle(fontSize: screenWidth * 0.04)),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  margin: EdgeInsets.all(screenWidth * 0.02),
                                ),
                              );
                            },
                            child: Text('حذف', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('حذف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    final filteredMeals = _meals.where((meal) => meal.category == _selectedCategory).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            "إدارة القائمة",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              onPressed: () => _showAddCategoryDialog(context, screenWidth),
              icon: Icon(Icons.add_box_outlined, size: screenWidth * 0.06, color: Colors.orange),
              tooltip: 'إضافة قسم جديد',
            ),
            IconButton(
              onPressed: () => _showManageCategoriesDialog(context, screenWidth),
              icon: Icon(Icons.restaurant_menu, size: screenWidth * 0.06, color: Colors.orange),
              tooltip: 'إدارة الأقسام',
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // الأقسام
            SizedBox(
              height: screenWidth < 400 ? 80 : 80, // Responsive height
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 10),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  final mealsCount = _meals.where((meal) => meal.category == cat).length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth < 400 ? 9 : 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? Colors.orange.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                            blurRadius: isSelected ? 8 : 4,
                            offset: Offset(0, isSelected ? 4 : 2),
                          ),
                        ],
                        border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade200, width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          if (mealsCount > 0) ...[
                            SizedBox(width: screenWidth * 0.01),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015, vertical: screenWidth * 0.005),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$mealsCount',
                                style: TextStyle(
                                  color: isSelected ? Colors.orange : Colors.orange[700],
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // محتوى الوجبات
            Expanded(
              child: filteredMeals.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: screenWidth * 0.15, color: Colors.grey[400]),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      "لا توجد وجبات في قسم $_selectedCategory",
                      style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      "اضغط على زر الإضافة لإضافة وجبة جديدة",
                      style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : (isDesktop
                  ? GridView.builder(
                padding: EdgeInsets.all(screenWidth * 0.04),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenWidth * 0.45,
                  mainAxisSpacing: screenWidth * 0.04,
                  crossAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: 2.5,
                ),
                itemCount: filteredMeals.length,
                itemBuilder: (context, idx) => _buildMealCard(filteredMeals[idx], screenWidth),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: filteredMeals.length,
                itemBuilder: (context, idx) => _buildMealCard(filteredMeals[idx], screenWidth),
              )),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          onPressed: () => _showAddMealDialog(context, screenWidth),
          icon: Icon(Icons.restaurant, color: Colors.white, size: screenWidth * 0.06),
          label: Text(
            "إضافة وجبة",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
          ),
          elevation: 6,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
      ),
    );
  }

  Widget _buildMealCard(MealModel meal, double screenWidth) {
    return GestureDetector(
      onTap: () => _showMealDetailsDialog(meal, context, screenWidth),
      child: Container(
        margin: EdgeInsets.only(bottom: screenWidth * 0.03),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                child: Stack(
                  children: [
                    Image.asset(
                      meal.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: screenWidth * 0.1, color: Colors.grey),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045, color: Colors.black87),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meal.category,
                          style: TextStyle(color: Colors.orange[700], fontSize: screenWidth * 0.035, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Text(
                    meal.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.035, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    children: [
                      Text(
                        "${meal.price.toStringAsFixed(0)} جنيه",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 1; // القائمة

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/restaurant-home');
          break;
        case 1:
          context.go('/Menu');
          break;
        case 2:
          context.go('/RestaurantAnalysisScreen');
          break;
        case 3:
          context.go('/SettingsProvider');
          break;
      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Menu_provider.svg", "label": "القائمة"},
      {"svg": "assets/icons/Nav_Analysis_provider.svg", "label": "الإحصائيات"},
      {"svg": "assets/icons/Settings.svg", "label": "الإعدادات"},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 10,
              horizontal: isTablet ? 20 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navIcons.length, (idx) {
                final item = navIcons[idx];
                final selected = idx == currentIndex;
                Color mainColor =
                selected ? Colors.orange : const Color(0xFF6B7280);

                return InkWell(
                  onTap: () => onItemTapped(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          item["svg"]!,
                          height: isTablet ? 28 : 24,
                          width: isTablet ? 28 : 24,
                          colorFilter:
                          ColorFilter.mode(mainColor, BlendMode.srcIn),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          item["label"]!,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
