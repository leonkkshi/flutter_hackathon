import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/video_view_model.dart';
import 'package:flutter_hackathon/feature/presentation/view/video_list_page.dart'; // import AppThemeColors

class VideoFormPage extends StatefulWidget {
  final VideoItem? existingVideo;
  const VideoFormPage({super.key, this.existingVideo});

  @override
  State<VideoFormPage> createState() => _VideoFormPageState();
}

class _VideoFormPageState extends State<VideoFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _thumbnailUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingVideo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingVideo?.description ?? '');
    _videoUrlController = TextEditingController(text: widget.existingVideo?.videoUrl ?? '');
    _thumbnailUrlController = TextEditingController(text: widget.existingVideo?.thumbnailUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<VideoViewModel>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final videoUrl = _videoUrlController.text.trim();
    final thumbnailUrl = _thumbnailUrlController.text.trim();

    VideoItem? savedVideo;
    if (widget.existingVideo != null) {
      savedVideo = await vm.updateVideo(
        id: widget.existingVideo!.id,
        title: title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );
    } else {
      savedVideo = await vm.addVideo(
        title: title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );
    }

    if (savedVideo != null && mounted) {
      Navigator.pop(context, savedVideo);
    }
  }

  String _extractYtId(String url) {
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/').last.split('?').first;
    } else if (url.contains('v=')) {
      return url.split('v=').last.split('&').first;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingVideo != null;
    final vm = context.watch<VideoViewModel>();

    return Scaffold(
      backgroundColor: AppThemeColors.bg,
      appBar: AppBar(
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEdit ? 'Cập nhật Video' : 'Thêm Video mới',
          style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF90CAF9)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppThemeColors.primary, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Hỗ trợ phát video dạng trực tuyến MP4 và nhúng liên kết YouTube.',
                                style: TextStyle(
                                  color: AppThemeColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Tiêu đề
                      _buildLabel('Tiêu đề *'),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Nhập tiêu đề video hướng dẫn...',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                      ),
                      const SizedBox(height: 14),

                      // Input Video URL
                      _buildLabel('Đường dẫn video (MP4 hoặc YouTube) *'),
                      _buildTextField(
                        controller: _videoUrlController,
                        hintText: 'https://example.com/video.mp4 hoặc YouTube link',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập đường dẫn';
                          if (!v.startsWith('http://') && !v.startsWith('https://')) {
                            return 'Đường dẫn phải bắt đầu bằng http:// hoặc https://';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Input Thumbnail URL
                      _buildLabel('Hình ảnh thu nhỏ (Tùy chọn)'),
                      _buildTextField(
                        controller: _thumbnailUrlController,
                        hintText: 'https://example.com/thumbnail.jpg (Để trống nếu dùng YouTube)',
                      ),
                      const SizedBox(height: 14),

                      // Input Mô tả
                      _buildLabel('Mô tả video'),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Nhập tóm tắt mô tả nội dung video...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action buttons Row
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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeColors.textSecondary,
                        side: const BorderSide(color: AppThemeColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: vm.isLoading ? null : _saveForm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppThemeColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Lưu',
                              style: TextStyle(
                                fontSize: 16,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppThemeColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: AppThemeColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppThemeColors.textHint, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppThemeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppThemeColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppThemeColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppThemeColors.error, width: 1.5),
        ),
      ),
    );
  }
}
