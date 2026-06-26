import 'package:flutter/foundation.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_video_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';

enum VideoStatus { initial, loading, success, failure }

class VideoViewModel extends ChangeNotifier {
  final IVideoService _videoService;

  VideoViewModel(this._videoService);

  VideoStatus _status = VideoStatus.initial;
  List<VideoItem> _allVideos = [];
  List<VideoItem> _filteredVideos = [];
  String _searchQuery = '';
  String? _errorMessage;

  VideoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoading => _status == VideoStatus.loading;
  List<VideoItem> get videos => _filteredVideos;

  Future<void> loadVideos() async {
    _status = VideoStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allVideos = await _videoService.getVideos();
      _applyFilter();
      _status = VideoStatus.success;
    } catch (e) {
      _status = VideoStatus.failure;
      _errorMessage = 'Không thể tải danh sách video. Vui lòng thử lại.';
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  Future<VideoItem?> addVideo({
    required String title,
    required String description,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    _status = VideoStatus.loading;
    notifyListeners();

    try {
      // Auto-extract youtube thumbnail if thumbnail is empty and it's a youtube url
      String finalThumb = thumbnailUrl.trim();
      if (finalThumb.isEmpty) {
        finalThumb = _getYouTubeThumbnail(videoUrl) ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500';
      }

      final newVideo = VideoItem(
        id: '', // repo will generate ID
        title: title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: finalThumb,
      );

      final addedVideo = await _videoService.addVideo(newVideo);
      await loadVideos();
      return addedVideo;
    } catch (e) {
      _status = VideoStatus.failure;
      _errorMessage = 'Không thể thêm video. Vui lòng thử lại.';
      notifyListeners();
      return null;
    }
  }

  Future<VideoItem?> updateVideo({
    required String id,
    required String title,
    required String description,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    _status = VideoStatus.loading;
    notifyListeners();

    try {
      String finalThumb = thumbnailUrl.trim();
      if (finalThumb.isEmpty) {
        finalThumb = _getYouTubeThumbnail(videoUrl) ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500';
      }

      final updatedVideo = VideoItem(
        id: id,
        title: title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: finalThumb,
      );

      final result = await _videoService.updateVideo(updatedVideo);
      await loadVideos();
      return result;
    } catch (e) {
      _status = VideoStatus.failure;
      _errorMessage = 'Không thể cập nhật video. Vui lòng thử lại.';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteVideo(String id) async {
    _status = VideoStatus.loading;
    notifyListeners();

    try {
      await _videoService.deleteVideo(id);
      await loadVideos();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Delete Error: $e');
      debugPrint('StackTrace: $stackTrace');
      _status = VideoStatus.failure;
      _errorMessage = 'Không thể xoá video: $e';
      notifyListeners();
      return false;
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredVideos = List.from(_allVideos);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredVideos = _allVideos
          .where((v) =>
              v.title.toLowerCase().contains(q) ||
              v.description.toLowerCase().contains(q))
          .toList();
    }
  }

  String? _getYouTubeThumbnail(String url) {
    if (url.contains('youtu.be/')) {
      final id = url.split('youtu.be/').last.split('?').first;
      return 'https://img.youtube.com/vi/$id/0.jpg';
    } else if (url.contains('v=')) {
      final id = url.split('v=').last.split('&').first;
      return 'https://img.youtube.com/vi/$id/0.jpg';
    } else if (url.contains('embed/')) {
      final id = url.split('embed/').last.split('?').first;
      return 'https://img.youtube.com/vi/$id/0.jpg';
    }
    return null;
  }
}
