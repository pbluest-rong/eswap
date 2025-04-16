import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/views/home/explore.dart';
import 'package:flutter/material.dart';

class SearchFilterSortProvider extends ChangeNotifier {
  String? keyword;
  List<int>? categoryIdList;
  List<int>? brandIdList;
  double? minPrice;
  double? maxPrice;
  Condition? condition;
  SortPostType? sortBy;

  void updateKeyword(String? keyword) {
    this.keyword = keyword;
    notifyListeners();
  }

  void updateCategoryIdList(List<int>? categoryIdList) {
    this.categoryIdList = categoryIdList;
    notifyListeners();
  }

  void updateBrandIdList(List<int>? brandIdList) {
    this.brandIdList = brandIdList;
    notifyListeners();
  }

  void updateMinPrice(double? minPrice) {
    this.minPrice = minPrice;
    notifyListeners();
  }

  void updateMaxPrice(double? maxPrice) {
    this.maxPrice = maxPrice;
    notifyListeners();
  }

  void updateCondition(Condition? condition) {
    this.condition = condition;
    notifyListeners();
  }

  void updateSortBy(SortPostType? sortBy) {
    this.sortBy = sortBy;
    notifyListeners();
  }

  Map<String, dynamic> toJsonForSearchFilterSortPosts() {
    Map<String, dynamic> show = {
      "keyword": keyword,
      "categoryIdList": categoryIdList,
      "brandIdList": brandIdList,
      "minPrice": minPrice,
      "maxPrice": maxPrice,
      "condition": condition?.name,
      "sortBy": sortBy?.name,
    };
    print(show);
    return {
      "keyword": keyword,
      "categoryIdList": categoryIdList,
      "brandIdList": brandIdList,
      "minPrice": minPrice,
      "maxPrice": maxPrice,
      "condition": condition?.name,
      "sortBy": sortBy?.name,
    };
  }

  void reset() {
    keyword = null;
    categoryIdList = null;
    brandIdList = null;
    minPrice = null;
    maxPrice = null;
    condition = null;
    sortBy = null;
    notifyListeners();
  }

  bool isNoFilter() {
    return
      keyword == null &&
          categoryIdList == null &&
          brandIdList == null &&
          minPrice == null &&
          maxPrice == null &&
          condition == null &&
          sortBy == null;
  }
}
