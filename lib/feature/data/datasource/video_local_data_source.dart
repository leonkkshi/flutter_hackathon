import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';

class VideoLocalDataSource {
  static const String _videosKey = 'saved_videos';
  final FlutterSecureStorage _storage;

  VideoLocalDataSource(this._storage);

  Future<List<VideoItem>> getVideos() async {
    final String? jsonStr = await _storage.read(key: _videosKey);
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      // Pre-populate with initial TAXAI mock videos
      final initialVideos = [
        const VideoItem(
          id: '1',
          title: 'Hướng dẫn tính Thuế TNCN 2026',
          description: 'Video chi tiết hướng dẫn cách tính thuế Thu nhập cá nhân mới nhất năm 2026 cho người lao động tại Việt Nam.',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          thumbnailUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=500',
        ),
        const VideoItem(
          id: '2',
          title: 'Kê khai Thuế Giá trị Gia tăng (VAT)',
          description: 'Hướng dẫn quy trình lập tờ khai và nộp thuế GTGT cho doanh nghiệp vừa và nhỏ, hỗ trợ bởi TAXAI.',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          thumbnailUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=500',
        ),
        const VideoItem(
          id: '3',
          title: 'Giới thiệu giải pháp Thuế thông minh TAXAI',
          description: 'Tìm hiểu các tính năng nổi bật của hệ sinh thái quản lý tài chính và tối ưu hóa thuế TAXAI.',
          videoUrl: 'https://www.youtube.com/watch?v=1w7OgIMMRc4', // YouTube official video
          thumbnailUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
        ),
      ];
      await saveVideos(initialVideos);
      return initialVideos;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVideos(List<VideoItem> videos) async {
    final String jsonStr = jsonEncode(videos.map((v) => v.toJson()).toList());
    await _storage.write(key: _videosKey, value: jsonStr);
  }
}
