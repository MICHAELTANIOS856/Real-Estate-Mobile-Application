enum ListingMode { rent, sale }

class Property {
  const Property({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.governorate,
    required this.mode,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrl,
    required this.lastConfirmed,
  });

  final String id;
  final String title;
  final String type;
  final String location;
  final String governorate;
  final ListingMode mode;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final int area;
  final String imageUrl;
  final String lastConfirmed;
}
