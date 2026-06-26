import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/video_view_model.dart';

// Blue/White Theme Design Tokens (synchronized with the rest of the app)
class AppThemeColors {
  static const primary = Color(0xFF1565C0);     // AppBar blue
  static const accent  = Color(0xFF1E88E5);     // Lighter blue
  static const fab     = Color(0xFF1976D2);     // FAB blue
  static const bg      = Color(0xFFF5F5F5);     // Screen background
  static const cardBg  = Colors.white;
  static const border  = Color(0xFFE0E0E0);
  static const searchBg = Color(0xFFF0F0F0);
  
  static const textPrimary   = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint      = Color(0xFFBDBDBD);
  static const error         = Color(0xFFE53935);
}

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoViewModel>().loadVideos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VideoViewModel>();

    return Scaffold(
      backgroundColor: AppThemeColors.bg,
      appBar: AppBar(
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Video Hướng dẫn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => vm.loadVideos(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(vm),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.videoForm,
        ),
        backgroundColor: AppThemeColors.fab,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Thêm video mới',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSearchBar(VideoViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppThemeColors.searchBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppThemeColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => vm.search(val),
                style: const TextStyle(fontSize: 15, color: AppThemeColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm video...',
                  hintStyle: TextStyle(color: AppThemeColors.textSecondary, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: AppThemeColors.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, VideoViewModel vm) {
    if (vm.isLoading) {
      return const _VideoSkeletonList();
    }

    if (vm.status == VideoStatus.failure) {
      return _buildErrorState(vm);
    }

    if (vm.videos.isEmpty) {
      return _buildEmptyState(context, vm);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.videos.length,
      itemBuilder: (ctx, i) {
        final video = vm.videos[i];
        return _buildVideoCard(context, video);
      },
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoItem video) {
    return Card(
      color: AppThemeColors.cardBg,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppThemeColors.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.videoDetail,
            arguments: video,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Thumbnail
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppThemeColors.searchBg,
                          child: const Icon(
                            Icons.video_collection_outlined,
                            color: AppThemeColors.textSecondary,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Play overlay
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            // Video Metadata
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
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

  Widget _buildEmptyState(BuildContext context, VideoViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.video_library_outlined,
            color: Colors.blue.shade300,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            vm.searchQuery.isEmpty ? 'Chưa có video nào' : 'Không tìm thấy video',
            style: const TextStyle(
              color: AppThemeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.searchQuery.isEmpty
                ? 'Hãy thêm video hướng dẫn mới để bắt đầu.'
                : 'Thử tìm kiếm với từ khóa khác.',
            style: const TextStyle(
              color: AppThemeColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (vm.searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.videoForm,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppThemeColors.fab,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Thêm video',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(VideoViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppThemeColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              color: AppThemeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              vm.errorMessage ?? 'Không thể tải dữ liệu.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => vm.loadVideos(),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoSkeletonList extends StatelessWidget {
  const _VideoSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 3,
      itemBuilder: (ctx, i) {
        return Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppThemeColors.border),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: _ShimmerBox(
                  radius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShimmerBox(height: 16, width: 200),
                    const SizedBox(height: 10),
                    const _ShimmerBox(height: 12, width: double.infinity),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? radius;

  const _ShimmerBox({this.width, this.height, this.radius});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _color = ColorTween(
      begin: const Color(0xFFE0E0E0),
      end: const Color(0xFFF5F5F5),
    ).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (ctx, anim) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: widget.radius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}
