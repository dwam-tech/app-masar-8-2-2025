// lib/screens/business/ResturantScreens/ResDataEdit.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saba2v2/providers/restaurant_profile_provider.dart';

class ResDataEdit extends StatefulWidget {
  const ResDataEdit({super.key});
  @override
  State<ResDataEdit> createState() => _ResDataEditState();
}

class _ResDataEditState extends State<ResDataEdit> {
  bool isEditMode = false;
  
  // Controllers for TextFields
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController restaurantNameController;
  late TextEditingController deliveryCostController;
  late TextEditingController depositAmountController;
  late TextEditingController maxPeopleController;
  late TextEditingController notesController;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeControllersWithProviderData();
  }

  void _initializeControllers() {
    usernameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    restaurantNameController = TextEditingController();
    deliveryCostController = TextEditingController();
    depositAmountController = TextEditingController();
    maxPeopleController = TextEditingController();
    notesController = TextEditingController();
  }

  /// Initialize controllers AFTER the data is fetched by the provider.
  void _initializeControllersWithProviderData() {
    final provider = context.read<RestaurantProfileProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.fetchDetails(); // Fetch data first
      _syncControllersWithProvider(); // Then sync controllers
    });
  }

  /// Syncs TextField controllers with the latest data from the provider.
  void _syncControllersWithProvider() {
    final provider = context.read<RestaurantProfileProvider>();
    final user = provider.restaurantData;
    final details = user?['restaurant_detail'];
    
    usernameController.text = user?['name'] ?? '';
    phoneController.text = user?['phone'] ?? '';
    emailController.text = user?['email'] ?? '';
    restaurantNameController.text = details?['restaurant_name'] ?? '';
    deliveryCostController.text = details?['delivery_cost_per_km']?.toString() ?? '0';
    depositAmountController.text = details?['deposit_amount']?.toString() ?? '0';
    maxPeopleController.text = details?['max_people_per_reservation']?.toString() ?? '0';
    notesController.text = details?['reservation_notes'] ?? '';
    
    _controllersInitialized = true;
    // Refresh the widget tree to show the new values.
    if(mounted) setState(() {});
  }

  @override
  void dispose() {
    // Dispose all controllers
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    restaurantNameController.dispose();
    deliveryCostController.dispose();
    depositAmountController.dispose();
    maxPeopleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  /// Handles logo upload
  Future<void> _pickAndUploadLogo() async {
    final provider = context.read<RestaurantProfileProvider>();
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      // The provider handles loading state and UI updates
      await provider.uploadDocument('logo_image', File(image.path));
      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!), backgroundColor: Colors.red));
      }
    }
  }

  /// Collects data from controllers and saves it
  Future<void> _saveData() async {
    final provider = context.read<RestaurantProfileProvider>();
    
    // Update the provider's data with the current controller values
    if (provider.restaurantData != null) {
      provider.restaurantData!['name'] = usernameController.text;
      provider.restaurantData!['phone'] = phoneController.text;
      
      if (provider.restaurantData!['restaurant_detail'] != null) {
        provider.restaurantData!['restaurant_detail']['restaurant_name'] = restaurantNameController.text;
        provider.restaurantData!['restaurant_detail']['delivery_cost_per_km'] = double.tryParse(deliveryCostController.text) ?? 0;
        provider.restaurantData!['restaurant_detail']['deposit_amount'] = double.tryParse(depositAmountController.text) ?? 0;
        provider.restaurantData!['restaurant_detail']['max_people_per_reservation'] = int.tryParse(maxPeopleController.text) ?? 0;
        provider.restaurantData!['restaurant_detail']['reservation_notes'] = notesController.text;
      }
    }
    
    // Call the provider's save method
    final success = await provider.saveChanges();
    
    // Show feedback
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green,
        ));
        setState(() => isEditMode = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'فشل حفظ البيانات'), backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The main widget is a Consumer that listens for changes
    return Consumer<RestaurantProfileProvider>(
      builder: (context, provider, child) {
        // Show a loading screen while initial data is being fetched
        if (provider.isLoading && provider.restaurantData == null) {
          return Scaffold(appBar: _buildAppBar(provider), body: const Center(child: CircularProgressIndicator(color: Colors.orange)));
        }
        
        // Show an error screen if fetching failed
        if (provider.error != null && provider.restaurantData == null) {
          return Scaffold(appBar: _buildAppBar(provider), body: Center(child: Text('خطأ: ${provider.error}')));
        }
        
        // Main UI after data is loaded
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: _buildAppBar(provider),
            body: _buildBody(provider),
          ),
        );
      },
    );
  }

  // --- BUILD METHODS ---
  
  PreferredSizeWidget _buildAppBar(RestaurantProfileProvider provider) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'تعديل بيانات المطعم',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        if (provider.isLoading) 
          const Padding(
            padding: EdgeInsets.all(16.0), 
            child: SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.orange)
            )
          ),
        if (!provider.isLoading) 
          IconButton(
            icon: Icon(
              isEditMode ? Icons.save_rounded : Icons.edit_rounded, 
              color: Colors.orange
            ),
            onPressed: () {
              if (isEditMode) {
                _saveData(); 
              } else {
                setState(() => isEditMode = true);
              }
            },
          ),
      ],
    );
  }

  Widget _buildBody(RestaurantProfileProvider provider) {
    final user = provider.restaurantData;
    final details = user?['restaurant_detail'];
    
    // If details are somehow null after loading, show an error.
    if(user == null || details == null) {
      return const Center(child: Text("لا توجد بيانات لعرضها."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalPadding = constraints.maxWidth > 600 ? 40 : 16;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAccountSection(user),
                  _buildDivider(),
                  _buildRestaurantInfoSection(details),
                  _buildDivider(),
                  _buildLogoSection(details),
                  _buildDivider(),
                  _buildDeliverySection(details),
                  _buildDivider(),
                  _buildReservationSection(details),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSection(Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'معلومات الحساب'),
        const SizedBox(height: 16),
        _buildField(
          "اسم المستخدم", 
          user['name'] ?? '', 
          controller: usernameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildField(
          "رقم الهاتف", 
          user['phone'] ?? '', 
          controller: phoneController,
          icon: Icons.phone_outlined,
          keyboard: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildField(
          "البريد الإلكتروني", 
          user['email'] ?? '', 
          controller: emailController, 
          editable: false,
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildRestaurantInfoSection(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'معلومات المطعم'),
        const SizedBox(height: 16),
        _buildField(
          "اسم المطعم", 
          details['restaurant_name'] ?? '', 
          controller: restaurantNameController,
          icon: Icons.restaurant_outlined,
        ),
      ],
    );
  }

  Widget _buildLogoSection(Map<String, dynamic> details) {
    String logoUrl = details['logo_image'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'شعار المطعم'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: logoUrl.startsWith('http')
                            ? Image.network(logoUrl, fit: BoxFit.cover)
                            : Image.file(File(logoUrl), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.restaurant, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'شعار المطعم',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      logoUrl.isNotEmpty ? 'تم رفع الشعار' : 'لم يتم رفع شعار',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditMode)
                ElevatedButton.icon(
                  onPressed: _pickAndUploadLogo,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text("تغيير"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'خدمة التوصيل'),
        const SizedBox(height: 16),
        _buildField(
          "تكلفة التوصيل لكل كيلومتر", 
          details['delivery_cost_per_km']?.toString() ?? '0', 
          controller: deliveryCostController,
          icon: Icons.delivery_dining_outlined,
          keyboard: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildReservationSection(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'حجز الطاولات'),
        const SizedBox(height: 16),
        _buildField(
          "مبلغ العربون", 
          details['deposit_amount']?.toString() ?? '0', 
          controller: depositAmountController,
          icon: Icons.payment_outlined,
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildField(
          "أقصى عدد أشخاص للحجز", 
          details['max_people_per_reservation']?.toString() ?? '0', 
          controller: maxPeopleController,
          icon: Icons.people_outline,
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildField(
          "ملاحظات الحجز", 
          details['reservation_notes'] ?? '', 
          controller: notesController,
          icon: Icons.note_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String value, {
    TextEditingController? controller,
    TextInputType? keyboard,
    int maxLines = 1,
    IconData? icon,
    bool editable = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: (isEditMode && editable) ? Colors.grey.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: (isEditMode && editable)
            ? Border.all(color: Colors.grey.shade300)
            : Border.all(color: Colors.transparent),
      ),
      child: (isEditMode && editable)
          ? TextField(
              controller: controller,
              keyboardType: keyboard,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: icon != null
                    ? Icon(icon, color: Colors.orange, size: 22)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.isNotEmpty ? value : "غير محدد",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: value.isNotEmpty
                                ? const Color(0xFF2D3748)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }
}