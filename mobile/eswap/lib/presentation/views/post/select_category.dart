import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/category_brand_model.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:flutter/material.dart';

class CategorySelectionWidget extends StatefulWidget {
  const CategorySelectionWidget({Key? key}) : super(key: key);

  @override
  _CategorySelectionWidgetState createState() =>
      _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  List<Category> categories = [];
  Category? selectedParentCategory;
  Category? selectedChildCategory;
  bool isLoading = true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: dialogHeight,
        minWidth: double.infinity,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            selectedParentCategory != null
                ? Row(
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
                  )
                : const Text(
                    'CHỌN DANH MỤC LIÊN QUAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (selectedParentCategory == null)
              _buildParentCategories()
            else
              _buildChildCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCategories() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5, // Reduced from 3 to allow more height
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
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
    );
  }

  Widget _buildChildCategories() {
    final children = selectedParentCategory?.children ?? [];
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: children.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final child = children[index];
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
      final result = {
        'parentCategory': {
          'id': selectedParentCategory!.id,
          'name': selectedParentCategory!.name,
        },
        'childCategory': {
          'id': selectedChildCategory!.id,
          'name': selectedChildCategory!.name,
        },
        // 'brands': selectedChildCategory!.brands,
      };
      // widget.onCategorySelected(result);
      Navigator.pop(context, result);
    }
  }
}
