import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<dynamic> mediaList;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.mediaList,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1}/${widget.mediaList.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final media = widget.mediaList[index];
          final url = media.originalUrl;
          final isVideo = url.toString().toLowerCase().endsWith('.mp4') ||
              url.toString().toLowerCase().endsWith('.mov');

          if (isVideo) {
            return _buildVideoViewer(url);
          } else {
            return _buildImageViewer(url);
          }
        },
      ),
    );
  }

  Widget _buildImageViewer(String url) {
    return Center(
      child: PhotoView(
        imageProvider: NetworkImage(url),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        heroAttributes: PhotoViewHeroAttributes(tag: url),
      ),
    );
  }

  Widget _buildVideoViewer(String url) {
    return Center(
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(url),
          autoPlay: true,
          looping: true,
          allowFullScreen: true,
        ),
      ),
    );
  }
}

