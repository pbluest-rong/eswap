import 'package:dio/dio.dart';
import 'package:eswap/core/theme/theme_constant.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:eswap/model/category_brand.dart';
import 'package:eswap/provider/search_filter_sort_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureCategories = fetchCategories(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Text("Lỗi: ${snapshot.error}");

        final categories = snapshot.data!;

        return CategoryChipSelector(childrenCategories: categories);
      },
    );
  }
}

Future<List<Category>> fetchCategories(BuildContext context) async {
  final dio = Dio();
  final languageCode = Localizations.localeOf(context).languageCode;
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final response = await dio.get(ServerInfo.getCategories,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Accept-Language": languageCode,
        "Authorization": "Bearer $accessToken",
      }));
  final data = response.data['data'] as List;
  return data.map((json) => Category.fromJson(json)).toList();
}

class CategoryChipSelector extends StatefulWidget {
  final List<Category> childrenCategories;

  const CategoryChipSelector({required this.childrenCategories});

  @override
  State<CategoryChipSelector> createState() => _CategoryChipSelectorState();
}

class _CategoryChipSelectorState extends State<CategoryChipSelector> {
  List<int> selectedIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<SearchFilterSortProvider>(context);
    selectedIds = List<int>.from(provider.categoryIdList ?? []);
  }

  void _handleSelectionChanged(List<int> newIds) {
    setState(() {
      selectedIds = newIds;
    });
    debugPrint("Selected IDs: $selectedIds");
    Provider.of<SearchFilterSortProvider>(context, listen: false)
        .updateCategoryIdList(selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: widget.childrenCategories.map((category) {
          return CategoryExpandableChip(
            category: category,
            selectedIds: selectedIds,
            onSelectionChanged: _handleSelectionChanged,
          );
        }).toList(),
      ),
    );
  }
}

class CategoryExpandableChip extends StatefulWidget {
  final Category category;
  final int level;
  final List<int> selectedIds;
  final Function(List<int>) onSelectionChanged;

  const CategoryExpandableChip({
    required this.category,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.level = 0,
    super.key,
  });

  @override
  State<CategoryExpandableChip> createState() => _CategoryExpandableChipState();
}

class _CategoryExpandableChipState extends State<CategoryExpandableChip> {
  bool _expanded = false;
  List<int> selectedBrandIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<SearchFilterSortProvider>(context);
    selectedBrandIds = List<int>.from(provider.brandIdList ?? []);
  }

  void _toggleBrand(int brandId) {
    setState(() {
      if (selectedBrandIds.contains(brandId)) {
        selectedBrandIds.remove(brandId);
      } else {
        selectedBrandIds.add(brandId);
      }
    });
    debugPrint("Selected Brand IDs: $selectedBrandIds");
    Provider.of<SearchFilterSortProvider>(context, listen: false)
        .updateBrandIdList(selectedBrandIds);
  }

  List<int> _getAllChildIds(Category category) {
    final ids = <int>[];
    for (final child in category.children) {
      ids.add(child.id);
      ids.addAll(_getAllChildIds(child));
    }
    return ids;
  }

  bool get _allChildrenSelected {
    final childIds = _getAllChildIds(widget.category);
    return childIds.isNotEmpty && childIds.every(widget.selectedIds.contains);
  }

  bool get _anyChildSelected {
    final childIds = _getAllChildIds(widget.category);
    return childIds.any(widget.selectedIds.contains);
  }

  void _toggleParentSelection() {
    final childIds = _getAllChildIds(widget.category);
    final newSelectedIds = List<int>.from(widget.selectedIds);

    if (_allChildrenSelected) {
      newSelectedIds.removeWhere(childIds.contains);
    } else {
      newSelectedIds
          .addAll(childIds.where((id) => !newSelectedIds.contains(id)));
    }

    widget.onSelectionChanged(newSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.category.children.isNotEmpty;
    final childIds = _getAllChildIds(widget.category);
    final isSelected = widget.selectedIds.contains(widget.category.id) ||
        (hasChildren && _allChildrenSelected);
    final isIndeterminate =
        hasChildren && _anyChildSelected && !_allChildrenSelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (hasChildren) ...[
              Checkbox(
                value: isSelected,
                tristate: true,
                onChanged: (_) => _toggleParentSelection(),
              ),
              SizedBox(width: 4),
            ] else
              Checkbox(
                value: widget.selectedIds.contains(widget.category.id),
                onChanged: (selected) {
                  final newIds = List<int>.from(widget.selectedIds);
                  selected!
                      ? newIds.add(widget.category.id)
                      : newIds.remove(widget.category.id);
                  widget.onSelectionChanged(newIds);
                },
              ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  widget.category.name,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (hasChildren)
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
          ],
        ),
        if (_expanded && widget.category.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: (widget.level + 1) * 16.0),
            child: Column(
              children: widget.category.children.map((child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: widget.selectedIds.contains(child.id),
                          onChanged: (selected) {
                            final newIds = List<int>.from(widget.selectedIds);
                            selected!
                                ? newIds.add(child.id)
                                : newIds.remove(child.id);
                            widget.onSelectionChanged(newIds);
                          },
                        ),
                        SizedBox(width: 8),
                        Text(child.name),
                      ],
                    ),
                    // Hiển thị brands nếu category có brands
                    if (child.brands.isNotEmpty &&
                        widget.selectedIds.contains(child.id))
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: child.brands.map((brand) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(brand.name),
                                  showCheckmark: false,
                                  selectedColor: AppColors.lightSecondary,
                                  selected: selectedBrandIds.contains(brand.id),
                                  onSelected: (_) => _toggleBrand(brand.id),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
