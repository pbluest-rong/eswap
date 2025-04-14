import 'package:eswap/provider/search_filter_sort_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildPriceFilter({
  required TextEditingController minPriceController,
  required TextEditingController maxPriceController,
  required VoidCallback onFilter,
  required BuildContext context,
}) {
  final provider = Provider.of<SearchFilterSortProvider>(context);

  minPriceController.text =
      provider.minPrice?.toString() ?? '';
  maxPriceController.text =
      provider.maxPrice?.toString() ?? '';

  return Row(
    children: [
      // Min Price
      Expanded(
        child: TextField(
          onSubmitted: (_) => onFilter(),
          controller: minPriceController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Từ',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          '-',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      // Max Price
      Expanded(
        child: TextField(
          onSubmitted: (_) => onFilter(),
          controller: maxPriceController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Đến',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    ],
  );
}
