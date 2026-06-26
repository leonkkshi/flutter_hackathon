import 'package:flutter/material.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/user_management_view_model.dart';
import 'package:provider/provider.dart';

class UserDetailPage extends StatelessWidget {
  final UserItem user;

  const UserDetailPage({super.key, required this.user});

  // Blue/white design tokens (mirrors UserManagementPage palette)
  static const _blue = Color(0xFF1565C0);
  static const _accent = Color(0xFF1E88E5);
  static const _bg = Color(0xFFF5F5F5);
  static const _textPrimary = Color(0xFF212121);
  static const _deleteRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserManagementViewModel>();
    final currentUser = vm.allUsers.firstWhere(
      (u) => u.id == user.id,
      orElse: () => user,
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay lại',
        ),
        title: const Text(
          'Chi tiết người dùng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Avatar + name header ──────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: currentUser.imageUrl.isNotEmpty
                        ? NetworkImage(currentUser.imageUrl)
                        : null,
                    child: currentUser.imageUrl.isEmpty
                        ? Text(
                            _initials(currentUser.fullName),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _blue,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    currentUser.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${currentUser.username}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: _accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Info rows ─────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: currentUser.email.isNotEmpty ? currentUser.email : '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Số điện thoại',
                    value: currentUser.phone.isNotEmpty ? currentUser.phone : '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Tuổi',
                    value: currentUser.age > 0 ? '${currentUser.age}' : '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.wc_outlined,
                    label: 'Giới tính',
                    value: currentUser.gender.isNotEmpty ? currentUser.gender : '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Ngày sinh',
                    value: currentUser.birthDate.isNotEmpty ? currentUser.birthDate : '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ',
                    value: currentUser.address.isNotEmpty ? currentUser.address : '—',
                    multiLine: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action buttons ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Chỉnh sửa
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.userForm,
                          arguments: currentUser,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(
                        'Chỉnh sửa',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Xoá
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, currentUser),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Xoá',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _deleteRed,
                        side:
                            const BorderSide(color: _deleteRed, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserItem targetUser) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xoá người dùng'),
        content: Text('Bạn có chắc muốn xoá "${targetUser.fullName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              context.read<UserManagementViewModel>().deleteUser(targetUser.id);
              Navigator.pop(dialogCtx);       // close dialog
              Navigator.pop(context);         // go back to list
            },
            style: FilledButton.styleFrom(
                backgroundColor: _deleteRed),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

// ── Info row widget ────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiLine;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiLine = false,
  });

  static const _blue = Color(0xFF1565C0);
  static const _textPrimary = Color(0xFF212121);
  static const _textSecondary = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: multiLine
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: _blue, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 34),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: _blue, size: 22),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      color: Color(0xFFE0E0E0),
    );
  }
}
