import 'dart:io';

import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/presentation/components/pick_media.dart';
import 'package:eswap/presentation/views/chat/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  List<String> _selectedMedia = [];

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

  Future<void> _pickMedia() async {
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
      final List<String> tempPaths = [];

      for (var asset in result) {
        final file = await asset.file;
        if (file != null) {
          tempPaths.add(file.path);
        }
      }

      if (mounted) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.addAll(tempPaths);
        });
      }
    }
  }

  void _handleSend() {
    if (_selectedMedia.isNotEmpty) {
      widget.mediaFiles?.clear();
      widget.mediaFiles?.addAll(_selectedMedia);
      setState(() {
        _selectedMedia.clear();
      });
    }
    widget.onSend();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  Widget _buildMediaPreview() {
    if (_selectedMedia.isEmpty) return SizedBox.shrink();

    return Container(
      height: 60,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMedia.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Image.file(
                  File(_selectedMedia[index]),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMedia.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (Provider.of<ChatProvider>(context).isSendingMessage)
          const LinearProgressIndicator(),
        if (_selectedMedia.isNotEmpty) _buildMediaPreview(),
        GestureDetector(
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
                    onTap: _pickMedia,
                    child:
                        Icon(Icons.perm_media, color: AppColors.lightPrimary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_voice_outlined,
                      color: AppColors.lightPrimary),
                  const SizedBox(width: 4),
                  Icon(Icons.location_on_outlined,
                      color: AppColors.lightPrimary),
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
                  onTap: _handleSend, // Sử dụng hàm mới
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(Icons.send, color: AppColors.lightPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
