import 'package:flutter/material.dart';
import '../../models/featured_property.dart';

class PropertyCard extends StatelessWidget {
  final FeaturedProperty property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // استخراج البيانات باستخدام الخصائص
    final title = property.type ?? 'عقار غير محدد';
    final location = property.address ?? 'غير محدد';
    final price = property.price != null ? '${property.price} جنيه' : 'غير محدد';
    final imageUrl = property.imageUrl ?? '';
    final area = property.area ?? 'غير محدد';
    final bedrooms = property.bedrooms?.toString() ?? 'غير محدد';
    final bathrooms = property.bathrooms?.toString() ?? 'غير محدد';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة مع badge للسعر
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.grey[200]!, Colors.grey[300]!],
                                ),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.grey[200]!, Colors.grey[300]!],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Badge السعر
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFC8700),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFC8700).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // أيقونة المفضلة
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              
              // المحتوى
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // الموقع
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // المساحة والغرف
                    Row(
                      children: [
                        // المساحة
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.square_foot,
                            label: 'المساحة',
                            value: '$area م²',
                          ),
                        ),
                        const SizedBox(width: 16),
                        // الغرف
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.king_bed,
                            label: 'غرف النوم',
                            value: '$bedrooms غرف',
                          ),
                        ),
                        const SizedBox(width: 16),
                        // الحمامات
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.bathtub,
                            label: 'الحمامات',
                            value: '$bathrooms حمام',
                          ),
                        ),
                      ],
                    ),
                    
                    // معلومات إضافية
                    if (property.view.isNotEmpty || property.paymentMethod.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 12),
                          if (property.view.isNotEmpty)
                            _buildAdditionalInfo(
                              icon: Icons.visibility,
                              label: 'الإطلالة',
                              value: property.view,
                            ),
                          if (property.view.isNotEmpty && property.paymentMethod.isNotEmpty)
                            const SizedBox(height: 8),
                          if (property.paymentMethod.isNotEmpty)
                            _buildAdditionalInfo(
                              icon: Icons.payment,
                              label: 'طريقة الدفع',
                              value: property.paymentMethod,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFC8700).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFFC8700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}