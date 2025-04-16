import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class EnhancedDraggableSheet extends StatefulWidget {
  final Widget child;
  final double minSize;
  final double maxSize;
  final List<double> snapSizes;
  final Color backgroundColor;

  const EnhancedDraggableSheet({
    super.key,
    required this.child,
    this.minSize = 0.1,
    this.maxSize = 0.9,
    this.snapSizes = const [0.2, 0.5, 0.8],
    this.backgroundColor = Colors.white,
  });

  @override
  State<EnhancedDraggableSheet> createState() => _EnhancedDraggableSheetState();
}

class _EnhancedDraggableSheetState extends State<EnhancedDraggableSheet>
    with SingleTickerProviderStateMixin {
  late final DraggableScrollableController _sheetController;
  late final ScrollController _scrollController;
  double _currentSize = 0.3;
  bool _isKeyboardVisible = false;
  double _initialSize = 0.3;
  bool _isInitialSizeCalculated = false;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _scrollController = ScrollController();
    _sheetController.addListener(_updateSheetSize);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_updateSheetSize);
    _sheetController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSheetSize() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _currentSize = _sheetController.size);
      }
    });
  }


  Future<void> _animateToSize(double size) async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      size.clamp(widget.minSize, widget.maxSize),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleKeyboard(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final newKeyboardState = viewInsets > 0;

    if (newKeyboardState != _isKeyboardVisible) {
      _isKeyboardVisible = newKeyboardState;
      if (_isKeyboardVisible) {
        _animateToSize(widget.maxSize);
      }
    }
  }

  void _calculateInitialSize(Size size, BoxConstraints constraints) {
    if (_isInitialSizeCalculated) return;

    final contentHeight = size.height + 60; // Thêm padding và indicator
    final screenHeight = constraints.maxHeight;
    final calculatedSize = (contentHeight / screenHeight).clamp(widget.minSize, widget.maxSize);

    if ((calculatedSize - _initialSize).abs() > 0.01) {
      setState(() {
        _initialSize = calculatedSize;
        _isInitialSizeCalculated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _handleKeyboard(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (_currentSize > widget.minSize)
              GestureDetector(
                onTap: () => _animateToSize(widget.minSize),
                child: Container(
                  color: Colors.black.withOpacity(0.4 * _currentSize),
                ),
              ),

            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _initialSize,
              minChildSize: widget.minSize,
              maxChildSize: widget.maxSize,
              snap: true,
              snapSizes: widget.snapSizes,
              builder: (context, scrollController) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MeasureSize(
                            onChange: (size) => _calculateInitialSize(size, constraints),
                            child: widget.child,
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null) widget.onChange(size);
    });

    return widget.child;
  }
}