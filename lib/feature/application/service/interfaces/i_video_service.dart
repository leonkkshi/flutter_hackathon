import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';

abstract interface class IVideoService {
  Future<List<VideoItem>> getVideos();
  Future<VideoItem> addVideo(VideoItem video);
  Future<VideoItem> updateVideo(VideoItem video);
  Future<void> deleteVideo(String videoId);
}
