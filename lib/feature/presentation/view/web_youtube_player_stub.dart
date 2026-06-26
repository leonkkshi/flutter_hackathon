import 'package:flutter/material.dart';

Widget buildWebYoutubePlayer(String videoId) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Không hỗ trợ phát YouTube trực tiếp trên nền tảng này. Vui lòng sử dụng ứng dụng di động hoặc mở trình duyệt.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
    ),
  );
}
