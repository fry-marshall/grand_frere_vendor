import '../../domain/entities/school.dart';

class SchoolModel {
  const SchoolModel({
    required this.id,
    required this.name,
    required this.sigle,
    required this.address,
    this.popular = false,
  });

  final String id;
  final String name;
  final String sigle;
  final String address;
  final bool popular;

  factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
        id: json['id'] as String,
        name: json['name'] as String,
        sigle: json['sigle'] as String,
        address: json['address'] as String,
        popular: json['popular'] as bool? ?? false,
      );

  School toDomain() => School(
        id: id,
        name: name,
        sigle: sigle,
        address: address,
        popular: popular,
      );
}
