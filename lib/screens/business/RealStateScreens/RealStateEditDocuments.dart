import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/real_estate_service.dart';

class RealStateEditDocuments extends StatefulWidget {
  const RealStateEditDocuments({super.key});

  @override
  State<RealStateEditDocuments> createState() => _RealStateEditDocumentsState();
}

class _RealStateEditDocumentsState extends State<RealStateEditDocuments> {
  bool isEditMode = false;
  bool _isLoading = false;
  bool _isDataLoading = true;
  
  final RealEstateService _realEstateService = RealEstateService();
  Map<String, dynamic>? _userData;
  String? _userType;
  
  // بيانات المستندات
  Map<String, String?> docs = {};
  bool includesVat = true;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isDataLoading = true);
      
      _userData = await _realEstateService.getCurrentUserData();
      
      if (_userData != null) {
        _userType = _userData!['user_type'];
        
        // تحديد البيانات حسب نوع المستخدم
        if (_userType == 'real_estate_office' && _userData!['real_estate']?['office_detail'] != null) {
          final officeDetail = _userData!['real_estate']['office_detail'];
          docs = {
            'ownerIdFront': officeDetail['owner_id_front_image'],
            'ownerIdBack': officeDetail['owner_id_back_image'],
            'officeImage': officeDetail['office_image'],
            'logoImage': officeDetail['logo_image'],
            'crPhotoFront': officeDetail['commercial_register_front_image'],
            'crPhotoBack': officeDetail['commercial_register_back_image'],
          };
          includesVat = officeDetail['tax_enabled'] == 1;
        } else if (_userType == 'real_estate_individual' && _userData!['real_estate']?['individual_detail'] != null) {
          final individualDetail = _userData!['real_estate']['individual_detail'];
          docs = {
            'profileImage': individualDetail['profile_image'],
            'agentIdFront': individualDetail['agent_id_front_image'],
            'agentIdBack': individualDetail['agent_id_back_image'],
            'taxCardFront': individualDetail['tax_card_front_image'],
            'taxCardBack': individualDetail['tax_card_back_image'],
          };
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isDataLoading = false);
    }
  }

  Future<void> _pickImage(String key) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        
        String? imageUrl = await _realEstateService.uploadImage(image.path);
        
        if (imageUrl != null) {
          setState(() {
            docs[key] = imageUrl;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع الصورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('فشل في رفع الصورة');
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الصورة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDocuments() async {
    try {
      setState(() => _isLoading = true);
      
      bool success = false;
      
      if (_userType == 'real_estate_office') {
        success = await _realEstateService.updateOfficeDocuments(
          ownerIdFrontImage: docs['ownerIdFront'],
          ownerIdBackImage: docs['ownerIdBack'],
          officeImage: docs['officeImage'],
          logoImage: docs['logoImage'],
          commercialRegisterFrontImage: docs['crPhotoFront'],
          commercialRegisterBackImage: docs['crPhotoBack'],
          taxEnabled: includesVat,
        );
      } else if (_userType == 'real_estate_individual') {
        success = await _realEstateService.updateIndividualDocuments(
          profileImage: docs['profileImage'],
          agentIdFrontImage: docs['agentIdFront'],
          agentIdBackImage: docs['agentIdBack'],
          taxCardFrontImage: docs['taxCardFront'],
          taxCardBackImage: docs['taxCardBack'],
        );
      }

      if (success) {
        setState(() => isEditMode = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ المستندات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('فشل في حفظ المستندات');
      }
    } catch (e) {
      debugPrint('Error saving documents: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ المستندات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0XFFF5F5F5),
          appBar: AppBar(
            title: Text(
              _userType == 'real_estate_office' ? 'مستندات المكتب' : 'مستندات السمسار',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
              onPressed: () => context.go("/RealStateEditProfile"),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0XFFF5F5F5),
        appBar: AppBar(
          title: Text(
            _userType == 'real_estate_office' ? 'مستندات المكتب' : 'مستندات السمسار',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
            onPressed: () => context.go("/RealStateEditProfile"),
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(isEditMode ? Icons.save : Icons.edit, color: Colors.orange),
                tooltip: isEditMode ? 'حفظ' : 'تعديل',
                onPressed: () {
                  if (isEditMode) {
                    _saveDocuments();
                  } else {
                    setState(() => isEditMode = true);
                  }
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildDocumentSections(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDocumentSections() {
    List<Widget> sections = [];

    if (_userType == 'real_estate_office') {
      // مستندات المكتب العقاري
      sections.addAll([
        const _SectionTitle(title: 'صور هوية المالك'),
        const SizedBox(height: 12),
        _buildImageRow('صورة أمامية', 'ownerIdFront'),
        const SizedBox(height: 12),
        _buildImageRow('صورة خلفية', 'ownerIdBack'),
        const SizedBox(height: 24),
        
        const _SectionTitle(title: 'صور المكتب'),
        const SizedBox(height: 12),
        _buildImageRow('صورة المكتب', 'officeImage'),
        const SizedBox(height: 12),
        _buildImageRow('شعار المكتب', 'logoImage'),
        const SizedBox(height: 24),
        
        const _SectionTitle(title: 'صور السجل التجاري'),
        const SizedBox(height: 12),
        _buildImageRow('صورة أمامية', 'crPhotoFront'),
        const SizedBox(height: 12),
        _buildImageRow('صورة خلفية', 'crPhotoBack'),
        const SizedBox(height: 24),
        
        const _SectionTitle(title: 'ضريبة القيمة المضافة'),
        const SizedBox(height: 12),
        _buildVatRow(context),
        const SizedBox(height: 15),
      ]);
    } else if (_userType == 'real_estate_individual') {
      // مستندات السمسار الفردي
      sections.addAll([
        const _SectionTitle(title: 'الصورة الشخصية'),
        const SizedBox(height: 12),
        _buildImageRow('الصورة الشخصية', 'profileImage'),
        const SizedBox(height: 24),
        
        const _SectionTitle(title: 'صور الهوية'),
        const SizedBox(height: 12),
        _buildImageRow('صورة أمامية', 'agentIdFront'),
        const SizedBox(height: 12),
        _buildImageRow('صورة خلفية', 'agentIdBack'),
        const SizedBox(height: 24),
        
        const _SectionTitle(title: 'صور البطاقة الضريبية'),
        const SizedBox(height: 12),
        _buildImageRow('صورة أمامية', 'taxCardFront'),
        const SizedBox(height: 12),
        _buildImageRow('صورة خلفية', 'taxCardBack'),
        const SizedBox(height: 15),
      ]);
    }

    return sections;
  }

  Widget _buildImageRow(String label, String key) {
    final imagePath = docs[key];
    return Row(
      children: [
        Container(
          width: 110,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey[100],
            image: imagePath != null && imagePath.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imagePath), 
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      debugPrint('Error loading image: $exception');
                    },
                  )
                : null,
          ),
          child: imagePath == null || imagePath.isEmpty
              ? Center(
                  child: Icon(Icons.image_outlined,
                      color: Colors.orange.shade200, size: 40),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        if (isEditMode)
          TextButton.icon(
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                : const Icon(Icons.upload_file, color: Colors.orange),
            label: Text(
              imagePath != null && imagePath.isNotEmpty ? 'تغيير' : 'رفع',
              style: const TextStyle(color: Colors.orange),
            ),
            onPressed: _isLoading ? null : () => _pickImage(key),
          ),
      ],
    );
  }

  Widget _buildVatRow(BuildContext context) {
    // ضريبة القيمة المضافة تظهر فقط للمكتب العقاري
    if (_userType != 'real_estate_office') {
      return const SizedBox.shrink();
    }

    if (!isEditMode) {
      return Row(
        children: [
          Icon(
            includesVat ? Icons.check_circle : Icons.cancel,
            color: includesVat ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            includesVat
                ? 'نعم، الأسعار تشمل الضريبة'
                : 'لا، الأسعار لا تشمل الضريبة',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: RadioListTile<bool>(
              title: const Text('تشمل الضريبة'),
              value: true,
              groupValue: includesVat,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => includesVat = val!),
            ),
          ),
          Expanded(
            child: RadioListTile<bool>(
              title: const Text('لا تشمل الضريبة'),
              value: false,
              groupValue: includesVat,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => includesVat = val!),
            ),
          ),
        ],
      );
    }
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
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
