import 'dart:convert';
import 'package:flutter/foundation.dart';

// Helper function to safely parse numbers from various types (String, int, double)
double safeParseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// Main response model
class AppointmentsResponse {
  final bool status;
  final List<Appointment> appointments;

  AppointmentsResponse({
    required this.status,
    required this.appointments,
  });

  factory AppointmentsResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentsResponse(
      status: json['status'] ?? false,
      appointments: (json['appointments'] as List<dynamic>?)
              ?.map((e) => Appointment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Appointment model
class Appointment {
  final int id;
  final DateTime appointmentDatetime;
  final String? note;
  final String? adminNote;
  final String status;
  final PropertyForAppointment property;
  final Customer customer;
  final ProviderUser provider;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.appointmentDatetime,
    this.note,
    this.adminNote,
    required this.status,
    required this.property,
    required this.customer,
    required this.provider,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      // Safely parse the datetime string
      appointmentDatetime: DateTime.parse(json['appointment_datetime'] as String),
      note: json['note'] as String?,
      adminNote: json['admin_note'] as String?,
      status: json['status'] as String,
      property: PropertyForAppointment.fromJson(json['property'] as Map<String, dynamic>),
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      provider: ProviderUser.fromJson(json['provider'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// A specific Property model for the appointment context to avoid conflicts
class PropertyForAppointment {
  final int id;
  final String address;
  final String type;
  final double price;
  final String imageUrl;
  final int bedrooms;
  final int bathrooms;
  final String area;
  final bool isReady;

  PropertyForAppointment({
    required this.id,
    required this.address,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.isReady,
  });

  factory PropertyForAppointment.fromJson(Map<String, dynamic> json) {
    return PropertyForAppointment(
      id: json['id'] as int,
      address: json['address'] as String,
      type: json['type'] as String,
      price: safeParseDouble(json['price']), // Use safe parsing
      imageUrl: json['image_url'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      area: json['area'] as String,
      isReady: json['is_ready'] == 1, // Convert int to bool
    );
  }
}

// Customer model
class Customer {
  final int id;
  final String name;
  final String? profileImage;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    this.profileImage,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      phone: json['phone'] as String,
    );
  }
}

// Provider model (represents the real estate office user)
class ProviderUser {
  final int id;
  final String name;

  ProviderUser({required this.id, required this.name});

  factory ProviderUser.fromJson(Map<String, dynamic> json) {
    return ProviderUser(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}