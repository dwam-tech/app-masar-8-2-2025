// import 'package:flutter/material.dart';
// import 'package:saba2v2/models/menu_section_model.dart';
// import 'package:saba2v2/models/restaurant.dart';

// import '../models/MenuSection.dart';

// /// مزود البيانات لإدارة قائمة المطاعم الموصى بها.
// class RestaurantProvider with ChangeNotifier {
//   final List<Restaurant> _recommendedRestaurants = [
//     Restaurant(
//       id: 'r1',
//       name: 'بيتزا هات',
//       category: 'مشويات',
//       imageUrl: 'assets/images/pizza_cover.jpg',
//       location: 'القاهرة',
//       logoUrl: 'assets/images/pizza_logo.jpg',
//       distanceKm: 3.5,
//       rating: 4.5,
//       reviews: 201,
//       openDays: 'السبت - الخميس',
//       openTime: '10:00 AM - 10:00 PM',
//       menuSections: [
//         MenuSection(
//           name: 'البيتزا',
//           items: [
//             MenuItem(
//               id: 'm1',
//               name: 'بيتزا دجاج',
//               imageUrl: 'assets/images/pizza_chicken.jpg',
//               description: 'بيتزا دجاج مع صوص المطاعم والخضار، إضافة جبنة موزاريلا.',
//               options: [
//                 MenuOption(label: 'الحجم الصغير', price: 200),
//                 MenuOption(label: 'الحجم الكبير', price: 250),
//               ],
//               basePrice: 200,
//             ),
//           ],
//         ),
//         MenuSection(
//           name: 'المشروبات',
//           items: [
//             MenuItem(
//               id: 'd1', // تصحيح الخطأ من 'idiopathic' إلى 'id'
//               name: 'كوكاكولا',
//               imageUrl: 'assets/images/cola.jpg',
//               description: 'كوكاكولا باردة.',
//               options: [],
//               basePrice: 20,
//             ),
//           ],
//         ),
//       ],
//     ),
//     Restaurant(
//       id: 'r2',
//       name: 'برجر كينج',
//       category: 'ساندويتشات',
//       imageUrl: 'assets/images/burger_cover.jpg',
//       location: 'الاسكندرية',
//       logoUrl: 'assets/images/burger_logo.jpg',
//       distanceKm: 2.1,
//       rating: 4.2,
//       reviews: 98,
//       openDays: 'كل أيام الأسبوع',
//       openTime: '11:00 AM - 12:00 AM',
//       menuSections: [
//         MenuSection(
//           name: 'البرجر',
//           items: [
//             MenuItem(
//               id: 'b1',
//               name: 'برجر لحم',
//               imageUrl: 'assets/images/burger.jpg',
//               description: 'برجر لحم مع جبنة وخضار وصوص خاص.',
//               options: [
//                 MenuOption(label: 'صغير', price: 170),
//                 MenuOption(label: 'وسط', price: 200),
//                 MenuOption(label: 'كبير', price: 250),
//               ],
//               basePrice: 170,
//             ),
//           ],
//         ),
//         MenuSection(
//           name: 'الإضافات',
//           items: [
//             MenuItem(
//               id: 'add1',
//               name: 'بطاطس',
//               imageUrl: 'assets/images/fries.jpg',
//               description: 'بطاطس مقلية مقرمشة.',
//               options: [],
//               basePrice: 35,
//             ),
//             MenuItem(
//               id: 'add2',
//               name: 'كاتشب',
//               imageUrl: 'assets/images/ketchup.jpg',
//               description: 'صوص كاتشب طازج.',
//               options: [],
//               basePrice: 5,
//             ),
//           ],
//         ),
//       ],
//     ),
//   ];

//   /// الحصول على قائمة المطاعم الموصى بها.
//   List<Restaurant> get recommendedRestaurants => _recommendedRestaurants;

//   /// البحث عن مطعم بناءً على المعرف (ID).
//   /// يرجع null إذا لم يتم العثور على المطعم.
//   Restaurant? getById(String id) {
//     try {
//       return _recommendedRestaurants.firstWhere((r) => r.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   /// إضافة مطعم جديد إلى القائمة.
//   void addRestaurant(Restaurant restaurant) {
//     _recommendedRestaurants.add(restaurant);
//     notifyListeners();
//   }

//   /// إزالة مطعم من القائمة بناءً على المعرف.
//   void removeRestaurant(String id) {
//     _recommendedRestaurants.removeWhere((r) => r.id == id);
//     notifyListeners();
//   }

//   /// إضافة عنصر جديد إلى قسم قائمة في مطعم معين.
//   void addMenuItem(String restaurantId, String sectionName, MenuItem item) {
//     final restaurant = getById(restaurantId);
//     if (restaurant != null) {
//       final section = restaurant.menuSections.firstWhere(
//             (s) => s.name == sectionName,
//         orElse: () => MenuSection(name: sectionName, items: []),
//       );
//       section.items.add(item);
//       if (!restaurant.menuSections.contains(section)) {
//         restaurant.menuSections.add(section);
//       }
//       notifyListeners();
//     }
//   }
// }