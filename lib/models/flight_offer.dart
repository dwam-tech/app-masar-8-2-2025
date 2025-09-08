class FlightOffer {
  final String id; // معرف العرض للحجز
  final String airline;
  final String flightNumber;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String from;
  final String to;
  final String fromCode; // كود المطار
  final String toCode; // كود المطار
  final double price;
  final String currency;
  final String duration;
  final String cabin; // درجة السفر
  final int availableSeats; // المقاعد المتاحة
  final String aircraft; // نوع الطائرة
  final List<String> amenities; // الخدمات المتاحة
  final bool refundable; // قابل للاسترداد
  final String fareType; // نوع التعرفة
  final Map<String, dynamic> rawData; // البيانات الخام من API

  FlightOffer({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.from,
    required this.to,
    required this.fromCode,
    required this.toCode,
    required this.price,
    required this.currency,
    required this.duration,
    required this.cabin,
    required this.availableSeats,
    required this.aircraft,
    required this.amenities,
    required this.refundable,
    required this.fareType,
    required this.rawData,
  });

  // MOCK
  static List<FlightOffer> mockList = [
    FlightOffer(
      id: "OFFER_1",
      airline: "EgyptAir",
      flightNumber: "MS735",
      departureTime: DateTime(2025, 1, 15, 14, 0),
      arrivalTime: DateTime(2025, 1, 15, 16, 25),
      from: "القاهرة، مصر",
      to: "اسطنبول، تركيا",
      fromCode: "CAI",
      toCode: "IST",
      price: 10400,
      currency: "EGP",
      duration: "2h 25m",
      cabin: "Economy",
      availableSeats: 9,
      aircraft: "Boeing 737-800",
      amenities: ["وجبة", "ترفيه", "WiFi"],
      refundable: true,
      fareType: "PUBLISHED",
      rawData: {},
    ),
    FlightOffer(
      id: "OFFER_2",
      airline: "EgyptAir",
      flightNumber: "MS737",
      departureTime: DateTime(2025, 1, 15, 17, 0),
      arrivalTime: DateTime(2025, 1, 15, 19, 25),
      from: "القاهرة، مصر",
      to: "اسطنبول، تركيا",
      fromCode: "CAI",
      toCode: "IST",
      price: 9800,
      currency: "EGP",
      duration: "2h 25m",
      cabin: "Economy",
      availableSeats: 15,
      aircraft: "Airbus A320",
      amenities: ["وجبة خفيفة", "ترفيه"],
      refundable: false,
      fareType: "PUBLISHED",
      rawData: {},
    ),
  ];
}
