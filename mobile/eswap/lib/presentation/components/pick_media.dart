import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';

class MediaLibraryScreen extends StatefulWidget {
  final int maxSelection;
  final bool isSelectImage;
  final bool isSelectVideo;
  final bool enableCamera;

  const MediaLibraryScreen({
    Key? key,
    this.maxSelection = 10,
    this.isSelectImage = true,
    this.isSelectVideo = false,
    this.enableCamera = false,
  }) : super(key: key);

  @override
  _MediaLibraryScreenState createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB cho ảnh
  static const int maxVideoSize = 20 * 1024 * 1024; // 20MB cho video
  final List<AssetEntity> _mediaList = [];
  final List<AssetEntity> _selectedMedia = [];
  final Map<String, Uint8List> _thumbnailCache = {};
  final Map<String, int> _assetIndices = {};
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoad();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAndLoad() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.hasAccess) {
      await _loadAlbums();
    } else {
      setState(() => _errorMessage = 'Không có quyền truy cập thư viện');
    }
  }

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);

    try {
      _albums = await PhotoManager.getAssetPathList(
        onlyAll: false,
        type: _getRequestType(),
      );
      if (_albums.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = true;
          _selectedAlbum = _albums.first;
          _loadMediaFromAlbum(reset: true);
        });
      } else {
        setState(() => _errorMessage = 'Không tìm thấy album');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi khi tải album');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  RequestType _getRequestType() {
    if (widget.isSelectImage && widget.isSelectVideo) {
      return RequestType.all;
    } else if (widget.isSelectImage) {
      return RequestType.image;
    } else if (widget.isSelectVideo) {
      return RequestType.video;
    }
    return RequestType.common;
  }

  Future<void> _loadMediaFromAlbum({bool reset = false}) async {
    print("PASS? $_selectedAlbum $_isLoading $_hasMore");
    print("RE: ${(_selectedAlbum == null || _isLoading || !_hasMore)}");
    if (_selectedAlbum == null || _isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 0;
        _mediaList.clear();
        _thumbnailCache.clear();
        _assetIndices.clear();
        _hasMore = true;
      }
    });

    try {
      final List<AssetEntity> media = await _selectedAlbum!.getAssetListPaged(
        page: _currentPage,
        size: 30,
      );

      print("CHECK MEDIA: $media");
      if (media.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        // Preload thumbnails for the first page
        if (reset) {
          await _preloadThumbnails(media);
        }

        setState(() {
          _mediaList.addAll(media);
          // Update indices for selection indicators
          for (int i = 0; i < _mediaList.length; i++) {
            _assetIndices[_mediaList[i].id] = i;
          }
          _currentPage++;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi khi tải media');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _preloadThumbnails(List<AssetEntity> assets) async {
    for (final asset in assets) {
      if (!_thumbnailCache.containsKey(asset.id)) {
        try {
          final thumbnail = await asset.thumbnailDataWithSize(
            const ThumbnailSize(200, 200), // Optimal size for grid
          );
          if (thumbnail != null) {
            _thumbnailCache[asset.id] = thumbnail;
          }
        } catch (e) {
          // Silently fail for individual thumbnails
        }
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMediaFromAlbum();
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null) return;

      // Kiểm tra dung lượng ảnh chụp
      final file = File(photo.path);
      final size = await file.length();
      if (size > maxImageSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ảnh không được vượt quá ${maxImageSize ~/ (1024*1024)}MB')),
        );
        return;
      }

      final bytes = await File(photo.path).readAsBytes();
      final filename = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final saved = await PhotoManager.editor.saveImage(
        bytes,
        title: filename,
        filename: filename,
      );

      if (saved != null) {
        // Preload the new photo's thumbnail
        final thumbnail = await saved.thumbnailDataWithSize(
          const ThumbnailSize(200, 200),
        );
        if (thumbnail != null) {
          _thumbnailCache[saved.id] = thumbnail;
        }

        setState(() {
          _mediaList.insert(0, saved);
          _assetIndices[saved.id] = 0;
          // Update indices for existing items
          for (int i = 1; i < _mediaList.length; i++) {
            _assetIndices[_mediaList[i].id] = i;
          }
        });

        if (_selectedMedia.length < widget.maxSelection) {
          setState(() => _selectedMedia.add(saved));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chụp ảnh: ${e.toString()}')),
        );
      }
    }
  }

  void _toggleSelection(AssetEntity asset) async {
    // Kiểm tra dung lượng trước khi chọn
    final isSizeValid = await _checkAssetSize(asset);
    if (!isSizeValid) return;

    setState(() {
      if (_selectedMedia.contains(asset)) {
        _selectedMedia.remove(asset);
      } else if (_selectedMedia.length < widget.maxSelection) {
        _selectedMedia.add(asset);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Bạn chỉ được chọn tối đa ${widget.maxSelection} media'),
          ),
        );
      }
    });
  }
  Future<bool> _checkAssetSize(AssetEntity asset) async {
    try {
      final file = await asset.file;
      if (file == null) return false;

      final size = await file.length();

      if (asset.type == AssetType.image && size > maxImageSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ảnh không được vượt quá ${maxImageSize ~/ (1024*1024)}MB')),
          );
        }
        return false;
      }

      if (asset.type == AssetType.video && size > maxVideoSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video không được vượt quá ${maxVideoSize ~/ (1024*1024)}MB')),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAlbumDropdown(),
        actions: [
          if (widget.enableCamera)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _takePhoto,
            ),
          if (_selectedMedia.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _selectedMedia.toList());
              },
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildMediaGrid(),
    );
  }

  Widget _buildAlbumDropdown() {
    if (_albums.isEmpty) return const Text('Thư viện ảnh');

    return FutureBuilder<int>(
      future: _selectedAlbum?.assetCountAsync,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data! : 0;
        return DropdownButton<AssetPathEntity>(
          value: _selectedAlbum,
          underline: Container(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
          items: _albums.map((album) {
            return DropdownMenuItem<AssetPathEntity>(
              value: album,
              child: FutureBuilder<int>(
                future: album.assetCountAsync,
                initialData: 0,
                builder: (context, snapshot) {
                  final albumCount = snapshot.hasData ? snapshot.data! : 0;
                  return Text(
                    '${album.name} ($albumCount)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                        ),
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (album) {
            if (album != null) {
              setState(() {
                _selectedAlbum = album;
                _loadMediaFromAlbum(reset: true);
              });
            }
          },
        );
      },
    );
  }

  Widget _buildMediaGrid() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_mediaList.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mediaList.isEmpty) {
      return const Center(child: Text('Không có media nào'));
    }

    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _mediaList.length + (_isLoading && _hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _mediaList.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildMediaItem(_mediaList[index]);
      },
    );
  }

  Widget _buildMediaItem(AssetEntity asset) {
    final isSelected = _selectedMedia.contains(asset);
    final isImage = asset.type == AssetType.image;
    final selectedIndex = isSelected ? _selectedMedia.indexOf(asset) + 1 : null;

    return GestureDetector(
      onTap: () => _toggleSelection(asset),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbnail(asset),
          if (!isImage) _buildVideoDuration(asset),
          if (isSelected) _buildSelectionIndicator(selectedIndex!),
          // Thêm hiển thị dung lượng
          _buildFileSize(asset),
        ],
      ),
    );
  }
  Widget _buildFileSize(AssetEntity asset) {
    return FutureBuilder<File?>(
      future: asset.file,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

        return FutureBuilder<int>(
          future: snapshot.data!.length(),
          builder: (context, sizeSnapshot) {
            if (!sizeSnapshot.hasData) return const SizedBox();

            final sizeInMB = sizeSnapshot.data! / (1024 * 1024);
            return Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${sizeInMB.toStringAsFixed(1)}MB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildThumbnail(AssetEntity asset) {
    if (_thumbnailCache.containsKey(asset.id)) {
      return Image.memory(
        _thumbnailCache[asset.id]!,
        fit: BoxFit.cover,
      );
    }

    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _thumbnailCache[asset.id] = snapshot.data!;
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: Colors.grey[300]);
      },
    );
  }

  Widget _buildVideoDuration(AssetEntity asset) {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _formatDuration(asset.duration),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(int index) {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return duration.inHours > 0
        ? "${duration.inHours}:$minutes:$secs"
        : "$minutes:$secs";
  }
}
