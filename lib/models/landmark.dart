class Landmark {
  final int? id;
  final String title;
  final double lat;
  final double lon;
  final String? image;

  Landmark({
    this.id,
    required this.title,
    required this.lat,
    required this.lon,
    this.image,
  });

  // Convert a Landmark into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': image,
    };
  }

  // Create a Landmark from a Map
  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as int?,
      title: json['title'] as String,
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
      image: json['image'] as String?,
    );
  }

  // Create a copy of the Landmark with updated values
  Landmark copyWith({
    int? id,
    String? title,
    double? lat,
    double? lon,
    String? image,
  }) {
    return Landmark(
      id: id ?? this.id,
      title: title ?? this.title,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      image: image ?? this.image,
    );
  }
}
