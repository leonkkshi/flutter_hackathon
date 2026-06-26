import 'package:flutter_hackathon/feature/application/service/interfaces/i_video_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_video_repository.dart';

class VideoServiceImpl implements IVideoService {
  final IVideoRepository _videoRepository;

  VideoServiceImpl(this._videoRepository);

  @override
  Future<List<VideoItem>> getVideos() async {
    return await _videoRepository.getVideos();
  }

  @override
  Future<VideoItem> addVideo(VideoItem video) async {
    return await _videoRepository.addVideo(video);
  }

  @override
  Future<VideoItem> updateVideo(VideoItem video) async {
    return await _videoRepository.updateVideo(video);
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    await _videoRepository.deleteVideo(videoId);
  }
}
