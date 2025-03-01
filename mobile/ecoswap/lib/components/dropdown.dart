import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  final String label;
  final List<String> list;
  final double menuMaxHeightValue;

  const Dropdown(
      {super.key,
      required this.label,
      required this.list,
      required this.menuMaxHeightValue});

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.list.isNotEmpty ? widget.list.first : '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        value: widget.list.isNotEmpty ? dropdownValue : null,
        decoration: InputDecoration(
          labelText: widget.label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F4FF),
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: widget.list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        dropdownColor: Colors.white,
        // Màu nền dropdown
        menuMaxHeight: widget.menuMaxHeightValue,
        alignment: Alignment.center,
      ),
    );
  }
}
