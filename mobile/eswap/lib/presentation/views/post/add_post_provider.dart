import 'package:eswap/model/enum_model.dart';
import 'package:flutter/cupertino.dart';

class AddPostProvider extends ChangeNotifier {
  int? categoryId;
  String? categoryName;
  String? name;
  String? description;
  int? brandId;
  double? originalPrice;
  double? salePrice;
  int? quantity = 1;
  String privacy = "PUBLIC";
  Condition? condition = Condition.NEW;
  String? address;
  String? phoneNumber;
  List<String>? images = [];
  List<String>? videos = [];
  int? storeId;
  String? storeName;

  void updateStore(int storeId, String storeName) {
    this.storeId = storeId;
    this.storeName = storeName;
    notifyListeners();
  }

  void updateCategory(int categoryId, String categoryName) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    notifyListeners();
  }

  void updateName(String name) {
    this.name = name;
    notifyListeners();
  }

  void updateDesc(String description) {
    this.description = description;
    notifyListeners();
  }

  void updateBrandId(int? brandId) {
    this.brandId = brandId;
    notifyListeners();
  }

  void updateOriginalPrice(double originalPrice) {
    this.originalPrice = originalPrice;
    notifyListeners();
  }

  void updateSalePrice(double salePrice) {
    this.salePrice = salePrice;
    notifyListeners();
  }

  void updateQuantity(int quantity) {
    this.quantity = quantity;
    notifyListeners();
  }

  void togglePrivacy() {
    privacy = privacy == "PUBLIC" ? "FOLLOWERS" : "PUBLIC";
    notifyListeners();
  }

  void updateCondition(Condition? condition) {
    this.condition = condition;
    notifyListeners();
  }

  void updateAddress(String address) {
    this.address = address;
    notifyListeners();
  }

  void updatePhoneNumber(String phoneNumber) {
    this.phoneNumber = phoneNumber;
    notifyListeners();
  }

  void addImage(String filePath) {
    images ??= [];
    images!.add(filePath);
    notifyListeners();
  }

  void removeImage(int index) {
    if (images!.length > index) {
      images!.removeAt(index);
      notifyListeners();
    }
  }

  void addVideo(String filePath) {
    videos ??= [];
    videos!.add(filePath);
    notifyListeners();
  }

  void removeVideo(int index) {
    if (videos!.length > index) {
      videos!.removeAt(index);
      notifyListeners();
    }
  }

  void clearMediaFiles() {
    if (images == null && videos == null) {
      return;
    } else {
      if (images != null) {
        images!.clear();
      }
      if (videos != null) {
        videos!.clear();
      }
      notifyListeners();
    }
  }

  bool isCanPost() {
    return categoryId != null &&
        categoryName != null &&
        name != null &&
        description != null &&
        salePrice != null &&
        quantity != null &&
        condition != null &&
        (getMediaFiles()?.isNotEmpty ?? false);
  }

  void reset() {
    categoryId = null;
    categoryName = null;
    name = null;
    description = null;
    brandId = null;
    originalPrice = null;
    salePrice = null;
    quantity = 1;
    privacy = "PUBLIC";
    condition = Condition.NEW;
    address = null;
    phoneNumber = null;
    images?.clear();
    videos?.clear();
  }

  Map<String, dynamic> toJson() {
    return {
      "categoryId": categoryId,
      "name": name,
      "description": description,
      "brandId": brandId,
      "originalPrice": originalPrice,
      "salePrice": salePrice,
      "quantity": quantity,
      "privacy": privacy,
      "condition": condition?.name,
      "address": address,
      "phoneNumber": phoneNumber,
      "storeId" : storeId
    };
  }

  List<String>? getMediaFiles() {
    if (images == null && videos == null) return null;

    List<String> mediaFiles = [];
    if (images != null) {
      mediaFiles.addAll(images!);
    }
    if (videos != null) {
      mediaFiles.addAll(videos!);
    }
    return mediaFiles;
  }
}
