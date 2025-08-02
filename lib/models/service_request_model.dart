import 'dart:convert';

// دالة مساعدة لتحويل قائمة JSON إلى قائمة موديلات
List<ServiceRequest> serviceRequestFromJson(String str) => List<ServiceRequest>.from(json.decode(str).map((x) => ServiceRequest.fromJson(x)));

class ServiceRequest {
    final int id;
    final int userId;
    final String governorate;
    final String type; // "rent" or "delivery"
    final String status; // "approved"
    final RequestData requestData;
    final DateTime createdAt;
    final DateTime updatedAt;

    ServiceRequest({
        required this.id,
        required this.userId,
        required this.governorate,
        required this.type,
        required this.status,
        required this.requestData,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
        id: json["id"],
        userId: json["user_id"],
        governorate: json["governorate"],
        type: json["type"],
        status: json["status"],
        requestData: RequestData.fromJson(json["request_data"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );
}

class RequestData {
    final int? price;
    final String? driver;
    final String? source;
    final String? toDate;
    final String? carModel;
    final String? fromDate;
    final String governorate;
    final String? rentalType;
    final String? carCategory;
    final String? clientNotes;
    // حقول خاصة بالتوصيل قد تكون null في حالة التأجير
    final String? fromLocation;
    final String? toLocation;


    RequestData({
        this.price,
        this.driver,
        this.source,
        this.toDate,
        this.carModel,
        this.fromDate,
        required this.governorate,
        this.rentalType,
        this.carCategory,
        this.clientNotes,
        this.fromLocation,
        this.toLocation,
    });

    factory RequestData.fromJson(Map<String, dynamic> json) => RequestData(
        price: json["price"],
        driver: json["driver"],
        source: json["source"],
        toDate: json["to_date"],
        carModel: json["car_model"],
        fromDate: json["from_date"],
        governorate: json["governorate"],
        rentalType: json["rental_type"],
        carCategory: json["car_category"],
        clientNotes: json["client_notes"],
        fromLocation: json["from_location"], // Fixed: using snake_case
        toLocation: json["to_location"],     // Fixed: using snake_case
    );
}