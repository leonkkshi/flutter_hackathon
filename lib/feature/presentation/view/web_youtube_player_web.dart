import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildWebYoutubePlayer(String videoId) {
  final String viewType = 'youtube-$videoId';
  
  // Register the iframe view factory using modern dart:ui_web
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    return html.IFrameElement()
      ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
      ..allowFullscreen = true;
  });
  
  return HtmlElementView(viewType: viewType);
}
