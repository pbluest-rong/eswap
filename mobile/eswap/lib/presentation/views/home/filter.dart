import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/theme/theme.dart';
import 'package:eswap/presentation/widgets/price_filter.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:eswap/presentation/views/home/category_chip_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterDialog extends StatefulWidget {
  final VoidCallback? onClose;

  const FilterDialog({super.key, this.onClose});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollCategoriesController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollCategoriesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.7;

    return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: dialogHeight, minWidth: double.infinity),
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "category_brand".tr(),
                                    style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: dialogHeight / 1.8,
                                    child: Scrollbar(
                                      controller: _scrollCategoriesController,
                                      child: ListView(
                                        controller:
                                            _scrollCategoriesController,
                                        children: [
                                          CategoryPage(),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "condition".tr(),
                                    style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  _buildChoiceCondition(textTheme),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "price_range".tr(),
                                    style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  buildPriceFilter(
                                      minPriceController: minPriceController,
                                      maxPriceController: maxPriceController,
                                      onFilter: handleFilter,
                                      context: context),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(textTheme)
              ],
            ),
          );
        }));
  }

  Widget _buildChoiceCondition(TextTheme textTheme) {
    Condition? condition =
        Provider.of<SearchFilterSortProvider>(context, listen: true).condition;

    return Row(
      children: [
        ChoiceChip(
          label: Text("new".tr()),
          showCheckmark: false,
          selectedColor: AppColors.lightSecondary,
          selected:
              (condition != null && condition == Condition.NEW) ? true : false,
          onSelected: (_) => {
            Provider.of<SearchFilterSortProvider>(context, listen: false)
                .updateCondition(Condition.NEW)
          },
        ),
        SizedBox(
          width: 6,
        ),
        ChoiceChip(
          label: Text("used".tr()),
          showCheckmark: false,
          selectedColor: AppColors.lightSecondary,
          selected:
              (condition != null && condition == Condition.USED) ? true : false,
          onSelected: (_) => {
            Provider.of<SearchFilterSortProvider>(context, listen: false)
                .updateCondition(Condition.USED)
          },
        )
      ],
    );
  }

  Widget _buildSubmitButton(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Provider.of<SearchFilterSortProvider>(context, listen: false)
                  .reset();
            },
            child: Text("clear".tr()),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onClose?.call();
            },
            child: Text("apply".tr()),
          ),
        ),
      ],
    );
  }

  void handleFilter() {
    double? min = double.tryParse(minPriceController.text);
    double? max = double.tryParse(maxPriceController.text);

    if (min != null && max != null && min > max) {
      showErrorDialog(context, "error_max_price".tr());
      maxPriceController.text = '';
    } else {
      Provider.of<SearchFilterSortProvider>(context, listen: false)
          .updateMinPrice(min);
      Provider.of<SearchFilterSortProvider>(context, listen: false)
          .updateMaxPrice(max);
    }
  }
}
