import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final int? maxValue; // NEW: Optional maximum value
  final ValueChanged<int>? onChanged;

  const QuantitySelector({
    super.key,
    this.initialValue = 1,
    this.maxValue, // NEW
    this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue;
  }

  void _increment() {
    if (widget.maxValue == null || _quantity < widget.maxValue!) {
      setState(() {
        _quantity++;
        widget.onChanged?.call(_quantity);
      });
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.onChanged?.call(_quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decrement,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$_quantity',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _increment,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }
}
