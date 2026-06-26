import 'package:flutter_hackathon/feature/data/datasource/video_local_data_source.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_video_repository.dart';

class VideoRepositoryImpl implements IVideoRepository {
  final VideoLocalDataSource _localDataSource;

  VideoRepositoryImpl({
    required VideoLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<VideoItem>> getVideos() async {
    return await _localDataSource.getVideos();
  }

  @override
  Future<VideoItem> addVideo(VideoItem video) async {
    final videos = await _localDataSource.getVideos();
    // Generate simple ID if empty or if we want to ensure uniqueness
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newVideo = video.copyWith(id: newId);
    
    videos.add(newVideo);
    await _localDataSource.saveVideos(videos);
    return newVideo;
  }

  @override
  Future<VideoItem> updateVideo(VideoItem video) async {
    final videos = await _localDataSource.getVideos();
    final index = videos.indexWhere((v) => v.id == video.id);
    if (index != -1) {
      videos[index] = video;
      await _localDataSource.saveVideos(videos);
      return video;
    }
    throw Exception('Không tìm thấy video với ID: ${video.id}');
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    final videos = await _localDataSource.getVideos();
    print('Attempting to delete videoId: $videoId. Total videos before: ${videos.length}');
    videos.removeWhere((v) => v.id == videoId);
    print('Total videos after removeWhere: ${videos.length}');
    await _localDataSource.saveVideos(videos);
  }
}
