// Updated to support requires_country_selection without changing the original model structure.
import 'package:meta/meta.dart';
import 'dart:convert';

CategoriesModel categoriesModelFromJson(String str) =>
    CategoriesModel.fromJson(json.decode(str));

String categoriesModelToJson(CategoriesModel data) =>
    json.encode(data.toJson());

class CategoriesModel {
  final bool? success;
  final int? code;
  final String? message;
  final Data? data;

  CategoriesModel({this.success, this.code, this.message, this.data});

  factory CategoriesModel.fromJson(Map<String, dynamic> json) =>
      CategoriesModel(
        success: json["success"],
        code: json["code"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "message": message,
    "data": data!.toJson(),
  };
}

class Data {
  final List<Servicecategory>? servicecategories;

  Data({this.servicecategories});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    servicecategories: List<Servicecategory>.from(
      json["servicecategories"].map((x) => Servicecategory.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "servicecategories": List<dynamic>.from(
      servicecategories!.map((x) => x.toJson()),
    ),
  };
}

class Servicecategory {
  final int? id;
  final String? categoryName;
  final String? type;
  final dynamic categoryImageUrl;
  final bool? requiresCountrySelection;
  final List<Service>? services;

  Servicecategory({
    this.id,
    this.categoryName,
    this.type,
    this.categoryImageUrl,
    this.requiresCountrySelection,
    this.services,
  });

  static bool _parseBoolean(dynamic value) {
    if (value is bool) return value;
    return value?.toString().trim().toLowerCase() == 'true' ||
        value?.toString().trim() == '1';
  }

  factory Servicecategory.fromJson(
    Map<String, dynamic> json,
  ) => Servicecategory(
    id: json["id"],
    categoryName: json["category_name"],
    type: json["type"],
    categoryImageUrl: json["category_image_url"],
    requiresCountrySelection: _parseBoolean(
      json["requires_country_selection"] ?? json["requiresCountrySelection"],
    ),
    services: json["services"] != null
        ? List<Service>.from(json["services"].map((x) => Service.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_name": categoryName,
    "type": type,
    "category_image_url": categoryImageUrl,
    "requires_country_selection": requiresCountrySelection,
    "services": List<dynamic>.from(services!.map((x) => x.toJson())),
  };
}

class Service {
  final int? id;
  final String? serviceCategoryId;
  final String? companyId;
  final String? countryId;
  final CategoryServiceCompany? company;

  Service({
    this.id,
    this.serviceCategoryId,
    this.companyId,
    this.countryId,
    this.company,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["id"] is int
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ""),
    serviceCategoryId: json["service_category_id"]?.toString(),
    companyId: json["company_id"]?.toString(),
    countryId: json["country_id"]?.toString(),
    company: json["company"] is Map
        ? CategoryServiceCompany.fromJson(
            Map<String, dynamic>.from(json["company"]),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service_category_id": serviceCategoryId,
    "company_id": companyId,
    "country_id": countryId,
    "company": company?.toJson(),
  };
}

// Nested country details returned with category.services[].company.country.
class CategoryServiceCompany {
  final String? countryId;
  final CategoryServiceCountry? country;

  CategoryServiceCompany({this.countryId, this.country});

  factory CategoryServiceCompany.fromJson(Map<String, dynamic> json) =>
      CategoryServiceCompany(
        countryId: json["country_id"]?.toString(),
        country: json["country"] is Map
            ? CategoryServiceCountry.fromJson(
                Map<String, dynamic>.from(json["country"]),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
    "country_id": countryId,
    "country": country?.toJson(),
  };
}

class CategoryServiceCountry {
  final dynamic id;
  final String? countryName;
  final String? phoneNumberLength;
  final bool? enableOperatorLookup;

  CategoryServiceCountry({
    this.id,
    this.countryName,
    this.phoneNumberLength,
    this.enableOperatorLookup,
  });

  factory CategoryServiceCountry.fromJson(Map<String, dynamic> json) {
    final rawLookup =
        json["enable_operator_lookup"] ?? json["enableOperatorLookup"];
    final parsedLookup =
        rawLookup == true ||
        rawLookup?.toString().trim().toLowerCase() == "true" ||
        rawLookup?.toString() == "1";

    return CategoryServiceCountry(
      id: json["id"],
      countryName: (json["country_name"] ?? json["countryName"])?.toString(),
      phoneNumberLength:
          (json["phone_number_length"] ?? json["phoneNumberLength"])
              ?.toString(),
      enableOperatorLookup: parsedLookup,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "country_name": countryName,
    "phone_number_length": phoneNumberLength,
    "enable_operator_lookup": enableOperatorLookup,
  };
}
