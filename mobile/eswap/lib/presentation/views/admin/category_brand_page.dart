import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/model/category_brand_model.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/service/category_brand_service.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class AdminCategoryBrandPage extends StatefulWidget {
  const AdminCategoryBrandPage({Key? key}) : super(key: key);

  @override
  _AdminCategoryBrandPageState createState() => _AdminCategoryBrandPageState();
}

class _AdminCategoryBrandPageState extends State<AdminCategoryBrandPage> {
  List<Category> categories = [];
  Category? selectedParentCategory;
  Category? selectedChildCategory;
  bool isLoading = true;
  bool _isInitialLoad = true;

  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _categoryNameController.dispose();
    _brandNameController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await fetchCategories(context);
      if (mounted) {
        setState(() {
          categories = loadedCategories;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<List<Category>> fetchCategories(BuildContext context) async {
    final dio = Dio();
    final languageCode = Localizations.localeOf(context).languageCode;
    final userSession = await UserSession.load();
    final response = await dio.get(ApiEndpoints.getCategories,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Accept-Language": languageCode,
          "Authorization": "Bearer ${userSession!.accessToken}",
        }));
    final data = response.data['data'] as List;
    return data.map((json) => Category.fromJson(json)).toList();
  }

  Future<void> _onRefresh() async {
    await _loadCategories();
    if (selectedChildCategory != null) {
      _loadBrands(selectedChildCategory!.id);
    }
  }

  // Thay đổi phần build thành:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedParentCategory != null)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                setState(() {
                                  selectedChildCategory = null;
                                  selectedParentCategory = null;
                                });
                              },
                            ),
                            Text(
                              selectedParentCategory?.name ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  )),
            ),
            if (isLoading)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (selectedParentCategory == null)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return _buildCategoryItem(
                        category,
                        isSelected: selectedParentCategory?.id == category.id,
                        onTap: () {
                          setState(() {
                            selectedParentCategory = category;
                          });
                        },
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final child = selectedParentCategory!.children[index];
                      return _buildChildCategoryItem(
                        child,
                        isSelected: selectedChildCategory?.id == child.id,
                        onTap: () {
                          setState(() {
                            selectedChildCategory = child;
                          });
                          _handleCategorySelection();
                        },
                      );
                    },
                    childCount: selectedParentCategory!.children.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (selectedChildCategory != null) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _brands.map((brand) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(brand.item!.name),
                                showCheckmark: false,
                                selectedColor: AppColors.lightSecondary,
                                selected: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          // print(selectedParentCategory?.id);
                          // print(selectedChildCategory?.id);
                          onPressed: _showAddBrandDialog,
                          child: Text("Thêm thương hiệu"),
                        ),
                      ),
                    ],
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // print(selectedParentCategory?.id);
                        // print(selectedChildCategory?.id);
                        onPressed: _showAddCategoryDialog,
                        child: Text("Thêm danh mục"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCategory() async {
    if (_categoryNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter category name')),
      );
      return;
    }

    try {
      final newCategory = await _categoryBrandService.createCategory(
        context: context,
        parentCategoryId: selectedParentCategory?.id,
        name: _categoryNameController.text,
      );

      _loadCategories();

      _categoryNameController.clear();
      await _onRefresh();
    } catch (e, a) {
      print(a);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add category: $e')),
      );
    }
  }

  Future<void> _addBrand() async {
    if (selectedChildCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sub-category first')),
      );
      return;
    }

    if (_brandNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter brand name')),
      );
      return;
    }

    try {
      final newBrand = await _categoryBrandService.createBrand(
        context: context,
        categoryId: selectedChildCategory!.id,
        name: _brandNameController.text,
      );

      if (selectedChildCategory != null) {
        _loadBrands(selectedChildCategory!.id);
      }
      _brandNameController.clear();
      await _loadBrands(selectedChildCategory!.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add brand: $e')),
      );
    }
  }

  Future<void> _showAddCategoryDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(selectedParentCategory == null
              ? 'Thêm danh mục chính'
              : 'Thêm danh mục con'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              hintText: 'Tên danh mục',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('confirm'.tr()),
              onPressed: () async {
                Navigator.of(context).pop();
                await _addCategory();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddBrandDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm thương hiệu'),
          content: TextField(
            controller: _brandNameController,
            decoration: const InputDecoration(
              hintText: 'Tên thương hiệu',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('confirm'.tr()),
              onPressed: () async {
                Navigator.of(context).pop();
                await _addBrand();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(Category category,
      {bool isSelected = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Center(
          child: Text(
            category.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  final _categoryBrandService = CategoryBrandService();
  List<SearchFieldListItem<Brand>> _brands = [];

  Future<void> _loadBrands(int categoryId) async {
    try {
      final brands =
          await _categoryBrandService.fetchBrandsByCategoryId(categoryId);
      setState(() {
        _brands = brands.map((brand) {
          return SearchFieldListItem<Brand>(
            brand.name,
            item: brand,
            child: Text(brand.name),
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi tải thương hiệu, vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildChildCategoryItem(Category category,
      {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        category.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
    );
  }

  void _handleCategorySelection() {
    if (selectedParentCategory != null && selectedChildCategory != null) {
      _loadBrands(selectedChildCategory!.id);
    }
  }
}
