import 'package:flutter/material.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/user_management_view_model.dart';
import 'package:provider/provider.dart';

// ── Design tokens — Blue/White theme ──────────────────────────────────────
class _C {
  // Blues
  static const primary = Color(0xFF1565C0);     // AppBar blue
  static const accent  = Color(0xFF1E88E5);     // Lighter blue
  static const fab     = Color(0xFF1976D2);     // FAB blue

  // Neutrals
  static const bg      = Color(0xFFF5F5F5);     // Screen background
  static const border  = Color(0xFFE0E0E0);
  static const searchBg = Color(0xFFF0F0F0);

  // Text
  static const textPrimary   = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);

  // Action icons
  static const iconView   = Color(0xFF00ACC1);  // teal
  static const iconEdit   = Color(0xFF00ACC1);  // teal
  static const iconDelete = Color(0xFFE53935);  // red

  // Pagination
  static const pageActive = Color(0xFF1976D2);
  static const pageInactive = Color(0xFFBDBDBD);
}

// ── Page ──────────────────────────────────────────────────────────────────
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserManagementViewModel>();

    if (vm.status == UserManagementStatus.success && !_fadeCtrl.isCompleted) {
      _fadeCtrl.forward();
    }

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody(context, vm)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.userForm,
        ),
        backgroundColor: _C.fab,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Thêm người dùng',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {},
        tooltip: 'Menu',
      ),
      title: const Text(
        'Quản lý người dùng',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            _fadeCtrl.reset();
            context.read<UserManagementViewModel>().loadUsers();
          },
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _C.searchBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    context.read<UserManagementViewModel>().search(v),
                style: const TextStyle(fontSize: 15, color: _C.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm người dùng...',
                  hintStyle: TextStyle(color: _C.textSecondary, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: _C.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.border),
            ),
            child:
                const Icon(Icons.filter_alt_outlined, color: _C.accent, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserManagementViewModel vm) {
    if (vm.isLoading) return const _LoadingState();

    if (vm.status == UserManagementStatus.failure) {
      return _ErrorState(
        message: vm.errorMessage ?? 'Đã xảy ra lỗi.',
        onRetry: () {
          _fadeCtrl.reset();
          vm.loadUsers();
        },
      );
    }

    if (vm.pagedUsers.isEmpty && vm.status == UserManagementStatus.success) {
      return _EmptyState(query: vm.searchQuery);
    }

    return Column(
      children: [
        Expanded(
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: vm.pagedUsers.length,
              separatorBuilder: (context, sep) =>
                  const Divider(height: 1, color: _C.border),
              itemBuilder: (ctx, i) {
                final user = vm.pagedUsers[i];
                return _UserRow(
                  user: user,
                  onDelete: () => _showDeleteDialog(context, user),
                  onEdit: () => Navigator.pushNamed(
                    context,
                    AppRoutes.userForm,
                    arguments: user,
                  ),
                  onView: () => Navigator.pushNamed(
                    context,
                    AppRoutes.userDetail,
                    arguments: user,
                  ),
                );
              },
            ),
          ),
        ),
        _buildPagination(vm),
      ],
    );
  }

  Widget _buildPagination(UserManagementViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ArrowBtn(
            icon: Icons.chevron_left,
            enabled: vm.currentPage > 1,
            onTap: () => vm.goToPage(vm.currentPage - 1),
          ),
          const SizedBox(width: 4),
          ...List.generate(vm.totalPages, (i) {
            final page = i + 1;
            final active = page == vm.currentPage;
            return GestureDetector(
              onTap: () => vm.goToPage(page),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? _C.pageActive : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: active ? Colors.white : _C.textSecondary,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          _ArrowBtn(
            icon: Icons.chevron_right,
            enabled: vm.currentPage < vm.totalPages,
            onTap: () => vm.goToPage(vm.currentPage + 1),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UserItem user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xoá người dùng'),
        content:
            Text('Bạn có chắc muốn xoá "${user.fullName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              context.read<UserManagementViewModel>().deleteUser(user.id);
              Navigator.pop(dialogCtx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// ── User row ──────────────────────────────────────────────────────────────
class _UserRow extends StatelessWidget {
  final UserItem user;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const _UserRow({
    required this.user,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: _C.border,
            backgroundImage: user.imageUrl.isNotEmpty
                ? NetworkImage(user.imageUrl)
                : null,
            child: user.imageUrl.isEmpty
                ? Text(
                    _initials(user.fullName),
                    style: const TextStyle(
                      color: _C.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
                  style: const TextStyle(
                      fontSize: 13, color: _C.textSecondary),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                      fontSize: 12, color: _C.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IconBtn(
              icon: Icons.visibility_outlined,
              color: _C.iconView,
              tooltip: 'Xem',
              onTap: onView),
          const SizedBox(width: 6),
          _IconBtn(
              icon: Icons.edit_outlined,
              color: _C.iconEdit,
              tooltip: 'Sửa',
              onTap: onEdit),
          const SizedBox(width: 6),
          _IconBtn(
              icon: Icons.delete_outline,
              color: _C.iconDelete,
              tooltip: 'Xoá',
              onTap: onDelete),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          color: enabled ? _C.textPrimary : _C.pageInactive,
          size: 28,
        ),
      ),
    );
  }
}

// ── Loading state ─────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Skeleton rows
        ...List.generate(
          5,
          (i) => Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _Shimmer(width: 52, height: 52, radius: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Shimmer(width: 140, height: 14, radius: 4),
                      const SizedBox(height: 6),
                      _Shimmer(width: 100, height: 11, radius: 4),
                      const SizedBox(height: 4),
                      _Shimmer(width: 160, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // "Đang tải dữ liệu..." indicator — matches screenshot
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Đang tải dữ liệu...',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
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
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search, color: Colors.blue.shade300, size: 64),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'Chưa có người dùng' : 'Không tìm thấy kết quả',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
                ? 'Nhấn + để thêm người dùng mới'
                : 'Thử tìm kiếm từ khoá khác',
            style: const TextStyle(color: _C.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 64),
          const SizedBox(height: 16),
          const Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _C.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
