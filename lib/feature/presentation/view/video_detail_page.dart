import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/video_view_model.dart';
import 'package:flutter_hackathon/feature/presentation/view/video_list_page.dart'; // import AppThemeColors


class VideoDetailPage extends StatefulWidget {
  final VideoItem video;
  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoItem _currentVideo;
  
  // Players
  YoutubePlayerController? _ytController;
  VideoPlayerController? _mp4Controller;
  ChewieController? _chewieController;
  bool _isPlayerReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _initializePlayer();
  }

  String? _extractYoutubeId(String url) {
    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/').last.split('?').first;
      }
      if (url.contains('youtube.com/watch')) {
        return Uri.parse(url).queryParameters['v'];
      }
      if (url.contains('youtube.com/embed/')) {
        return url.split('youtube.com/embed/').last.split('?').first;
      }
    } catch (_) {}
    return null;
  }

  void _initializePlayer() {
    final url = _currentVideo.videoUrl.trim();
    final isYouTube = url.contains('youtube.com') || url.contains('youtu.be') || url.contains('youtube-nocookie.com');

    if (isYouTube) {
      final videoId = _extractYoutubeId(url);
      if (videoId != null && videoId.isNotEmpty) {
        _disposeMp4Player();
        
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
          ),
        );
        _isPlayerReady = true;
        _hasError = false;
      } else {
        _hasError = true;
      }
    } else {
      _disposeYtPlayer();
      
      try {
        _mp4Controller = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _chewieController = ChewieController(
                  videoPlayerController: _mp4Controller!,
                  autoPlay: false,
                  looping: false,
                  allowFullScreen: true,
                  materialProgressColors: ChewieProgressColors(
                    playedColor: AppThemeColors.accent,
                    handleColor: AppThemeColors.accent,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white38,
                  ),
                );
                _isPlayerReady = true;
                _hasError = false;
              });
            }
          }).catchError((error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isPlayerReady = false;
              });
            }
          });
      } catch (_) {
        _hasError = true;
      }
    }
  }

  void _disposeYtPlayer() {
    _ytController?.close();
    _ytController = null;
  }

  void _disposeMp4Player() {
    _chewieController?.dispose();
    _chewieController = null;
    _mp4Controller?.dispose();
    _mp4Controller = null;
  }

  @override
  void dispose() {
    _disposeYtPlayer();
    _disposeMp4Player();
    super.dispose();
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Xoá video',
          style: TextStyle(
            color: AppThemeColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xoá video "${_currentVideo.title}" không?',
          style: const TextStyle(
            color: AppThemeColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text(
              'Huỷ',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xoá',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    print('Dialog closed. confirmed: $confirmed, mounted: $mounted');
    if (confirmed == true && mounted) {
      print('Calling deleteVideo with id: ${_currentVideo.id}');
      final success = await context.read<VideoViewModel>().deleteVideo(_currentVideo.id);
      print('deleteVideo returned: $success, mounted: $mounted');
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xoá video thành công!'),
              backgroundColor: AppThemeColors.primary,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<VideoViewModel>().errorMessage ?? 'Không thể xoá video.'),
              backgroundColor: AppThemeColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopOrWeb = kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final isYt = _ytController != null;

    return Scaffold(
      backgroundColor: AppThemeColors.bg,
      appBar: AppBar(
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chi tiết Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Video Title (Top of screen)
                    Text(
                      _currentVideo.title,
                      style: const TextStyle(
                        color: AppThemeColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Embedded Video Player
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 450),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppThemeColors.border, width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _buildPlayer(isDesktopOrWeb, isYt),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Video Description Title
                    const Text(
                      'Mô tả',
                      style: TextStyle(
                        color: AppThemeColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Video Description Card
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppThemeColors.border, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _currentVideo.description,
                          style: const TextStyle(
                            color: AppThemeColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions: Thêm, Sửa, Xoá
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppThemeColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Button Thêm (Primary, Blue)
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final dynamic newVideo = await Navigator.pushNamed(
                          context,
                          AppRoutes.videoForm,
                        );
                        if (newVideo is VideoItem && mounted) {
                          setState(() {
                            _currentVideo = newVideo;
                            _initializePlayer();
                          });
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppThemeColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Thêm',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Button Sửa (Ghost, Border)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final dynamic updated = await Navigator.pushNamed(
                          context,
                          AppRoutes.videoForm,
                          arguments: _currentVideo,
                        );
                        if (updated is VideoItem && mounted) {
                          setState(() {
                            _currentVideo = updated;
                            _initializePlayer();
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeColors.textSecondary,
                        side: const BorderSide(color: AppThemeColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sửa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Button Xoá (Ghost/Red Border, Warning action)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showDeleteConfirmDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeColors.error,
                        side: const BorderSide(color: AppThemeColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Xoá',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(bool isDesktopOrWeb, bool isYt) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppThemeColors.error, size: 40),
              SizedBox(height: 12),
              Text(
                'Lỗi liên kết video không khả dụng.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isPlayerReady) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppThemeColors.accent),
        ),
      );
    }

    if (isYt && _ytController != null) {
      return YoutubePlayer(
        controller: _ytController!,
        aspectRatio: 16 / 9,
      );
    } else {
      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        return Chewie(
          controller: _chewieController!,
        );
      }
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: AppThemeColors.accent),
      ),
    );
  }
}
