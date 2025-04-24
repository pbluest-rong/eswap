import 'package:flutter/material.dart';

class AppSearch extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController? controller;

  const AppSearch({
    super.key,
    required this.onSearch,
    this.controller,
  });

  @override
  State<AppSearch> createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late final bool _isExternalController;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
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
    if (!_isExternalController) {
      _controller.dispose();
    }
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
                  final trimmed = value.trim();
                  if (trimmed.length >= 3) {
                    widget.onSearch(value);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Vui lòng nhập ít nhất 3 ký tự khác khoảng trắng'),
                      ),
                    );
                  }
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
              child: const Icon(Icons.clear, size: 18),
            ),
        ],
      ),
    );
  }

  String getSearchText() => _controller.text;
}
