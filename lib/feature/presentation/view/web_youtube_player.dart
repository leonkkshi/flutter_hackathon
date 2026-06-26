import 'web_youtube_player_stub.dart'
    if (dart.library.html) 'web_youtube_player_web.dart';

import 'package:flutter/material.dart';

Widget getWebYoutubePlayer(String videoId) {
  return buildWebYoutubePlayer(videoId);
}
