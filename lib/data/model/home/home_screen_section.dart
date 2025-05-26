import 'dart:convert';
import 'package:Talab/data/model/item/item_model.dart';


class HomeScreenSection {
  int? sectionId;
  String? title;
  String? slug;
  int? sequence;
  String? filter;
  String? value; // JSON-encoded array for banner sections
  String? style;
  int? minPrice;
  int? maxPrice;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? totalData;
  List<ItemModel>? sectionData;

  HomeScreenSection({
    this.sectionId,
    this.title,
    this.slug,
    this.sequence,
    this.filter,
    this.value,
    this.style,
    this.minPrice,
    this.maxPrice,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.totalData,
    this.sectionData,
  });
  List<String> get bannerData => bannerImages; 
  // Getter to parse banner images from value field
  List<String> get bannerImages {
    if (filter == 'banner' && value != null) {
      try {
        return List<String>.from(jsonDecode(value!));
        
      } catch (e) {
        print('Error decoding banner images: $e');
        return [];
      }
    }
    return [];
  }

  HomeScreenSection.fromJson(Map<String, dynamic> json) {
    sectionId = json['id'];
    title = json['title'];
    slug = json['slug'];
    sequence = json['sequence'];
    filter = json['filter'];
    value = json['value'];
    style = json['style'];
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalData = json['total_data'];
    if (json['section_data'] != null && json['section_data'] is List && json['filter'] != 'banner') {
  sectionData = <ItemModel>[];
  json['section_data'].forEach((v) {
    sectionData!.add(ItemModel.fromJson(v));
  });
}

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sectionId;
    data['title'] = title;
    data['slug'] = slug;
    data['sequence'] = sequence;
    data['filter'] = filter;
    data['value'] = value;
    data['style'] = style;
    data['min_price'] = minPrice;
    data['max_price'] = maxPrice;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['total_data'] = totalData;
    if (sectionData != null) {
      data['section_data'] = sectionData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SectionData {
  int? id;
  String? name;
  String? description;
  int? price;
  String? image;
  String? watermarkImage; // Renamed for consistency
  double? latitude;
  double? longitude;
  String? address;
  String? contact;
  String? type;
  String? status;
  int? active;
  String? videoLink;
  UserDetails? userDetails;
  List<GalleryImages>? galleryImages;
  int? clicks;
  int? likes;
  List<CustomFields>? customFields;

  SectionData({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.watermarkImage,
    this.latitude,
    this.longitude,
    this.address,
    this.contact,
    this.type,
    this.status,
    this.active,
    this.videoLink,
    this.userDetails,
    this.galleryImages,
    this.clicks,
    this.likes,
    this.customFields,
  });

  SectionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
    watermarkImage = json['watermarkimage'];
    latitude = json['latitude']?.toDouble();
    longitude = json['longitude']?.toDouble();
    address = json['address'];
    contact = json['contact'];
    type = json['type'];
    status = json['status'];
    active = json['active'];
    videoLink = json['video_link'];
    userDetails = json['user_details'] != null
        ? UserDetails.fromJson(json['user_details'])
        : null;
    if (json['gallery_images'] != null) {
      galleryImages = <GalleryImages>[];
      json['gallery_images'].forEach((v) {
        galleryImages!.add(GalleryImages.fromJson(v));
      });
    }
    clicks = json['clicks'];
    likes = json['likes'];
    if (json['custom_fields'] != null) {
      customFields = <CustomFields>[];
      json['custom_fields'].forEach((v) {
        customFields!.add(CustomFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['image'] = image;
    data['watermarkimage'] = watermarkImage;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['contact'] = contact;
    data['type'] = type;
    data['status'] = status;
    data['active'] = active;
    data['video_link'] = videoLink;
    if (userDetails != null) {
      data['user_details'] = userDetails!.toJson();
    }
    if (galleryImages != null) {
      data['gallery_images'] = galleryImages!.map((v) => v.toJson()).toList();
    }
    data['clicks'] = clicks;
    data['likes'] = likes;
    if (customFields != null) {
      data['custom_fields'] = customFields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserDetails {
  int? id;
  String? name;
  String? mobile;
  String? email;
  String? type;
  String? profile;
  String? fcmId;
  String? firebaseId;
  int? status;
  String? apiToken;
  String? address; // Changed from Null to String? for consistency
  String? createdAt;
  String? updatedAt;

  UserDetails({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.type,
    this.profile,
    this.fcmId,
    this.firebaseId,
    this.status,
    this.apiToken,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  UserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    type = json['type'];
    profile = json['profile'];
    fcmId = json['fcm_id'];
    firebaseId = json['firebase_id'];
    status = json['status'];
    apiToken = json['api_token'];
    address = json['address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['email'] = email;
    data['type'] = type;
    data['profile'] = profile;
    data['fcm_id'] = fcmId;
    data['firebase_id'] = firebaseId;
    data['status'] = status;
    data['api_token'] = apiToken;
    data['address'] = address;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class GalleryImages {
  int? id;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? itemId;

  GalleryImages({
    this.id,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.itemId,
  });

  GalleryImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemId = json['item_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_id'] = itemId;
    return data;
  }
}

class CustomFields {
  int? id;
  String? name;
  String? type;
  String? image;
  List<String>? value;

  CustomFields({
    this.id,
    this.name,
    this.type,
    this.image,
    this.value,
  });

  CustomFields.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    image = json['image'];
    value = json['value']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['image'] = image;
    data['value'] = value;
    return data;
  }
}