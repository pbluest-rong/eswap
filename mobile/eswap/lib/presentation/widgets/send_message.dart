import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/presentation/components/pick_media.dart';
import 'package:flutter/material.dart';

class SendMessageWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  List<String>? mediaFiles;

  SendMessageWidget(
      {Key? key,
      required this.controller,
      required this.onSend,
      this.mediaFiles = const []})
      : super(key: key);

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (!_isFocused) ...[
              GestureDetector(
                  onTap: () async {
                    widget.mediaFiles!.clear();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaLibraryScreen(
                          maxSelection: 3,
                          isSelectImage: true,
                          isSelectVideo: true,
                          enableCamera: true,
                        ),
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      for (var asset in result) {
                        final file = await asset.file;
                        widget.mediaFiles!.add(file!.path);
                      }
                      widget.onSend();
                    }
                  },
                  child: Icon(Icons.perm_media, color: AppColors.lightPrimary)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_voice_outlined,
                  color: AppColors.lightPrimary),
              const SizedBox(width: 4),
              Icon(Icons.location_on_outlined, color: AppColors.lightPrimary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: "Aa",
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 3,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(height: 1),
                onSubmitted: (value) {
                  // Prevent Enter from submitting the message
                },
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                widget.onSend();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).unfocus();
                });
              },
              child: Icon(Icons.send, color: AppColors.lightPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
