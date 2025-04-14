import 'package:flutter/material.dart';

class AppSearch extends StatefulWidget {
  final Function(String) onSearch;

  const AppSearch({super.key, required this.onSearch});

  @override
  State<AppSearch> createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showClear = _focusNode.hasFocus && _controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xF5F5F5FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: (value) {
                  widget.onSearch(value);
                  _focusNode.unfocus();
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Nhập từ khóa tìm kiếm',
                ),
              ),
            ),
          ),
          if (showClear)
            GestureDetector(
              onTap: () {
                _controller.clear();
              },
              child: Icon(Icons.clear, size: 18),
            ),
        ],
      ),
    );
  }

  String getSearchText() {
    return _controller.text;
  }
}
