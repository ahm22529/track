class Locations {
  double? lat;
  double? lng;

  Locations({this.lat, this.lng});

  factory Locations.fromJson(Map<String, dynamic> json) => Locations(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}
