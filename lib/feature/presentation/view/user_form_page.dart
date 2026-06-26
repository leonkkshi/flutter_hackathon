import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/user_management_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────
class _C {
  static const teal       = Color(0xFF00897B);   // AppBar + Lưu button
  static const tealLight  = Color(0xFFE0F2F1);
  static const green      = Color(0xFF43A047);   // checkmark + validation hint
  static const bg         = Color(0xFFF5F5F5);
  static const border     = Color(0xFFBDBDBD);
  static const borderFocus= Color(0xFF00897B);
  static const error      = Color(0xFFE53935);
  static const textPrimary   = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint      = Color(0xFFBDBDBD);
}

// ── Page ──────────────────────────────────────────────────────────────────
/// Pass [existingUser] for edit mode; null for add mode.
class UserFormPage extends StatefulWidget {
  final UserItem? existingUser;

  const UserFormPage({super.key, this.existingUser});

  bool get isEditMode => existingUser != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _passwordCtrl;

  String _gender = 'Nam';
  bool _obscurePassword = true;
  bool _isSaving = false;

  // Track which fields have been touched for live checkmarks
  final Set<String> _valid = {};

  String? _pickedImagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _pickedImagePath = xfile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final u = widget.existingUser;
    _firstNameCtrl = TextEditingController(
        text: u != null ? _firstName(u.fullName) : '');
    _lastNameCtrl = TextEditingController(
        text: u != null ? _lastName(u.fullName) : '');
    _usernameCtrl = TextEditingController(text: u?.username ?? '');
    _emailCtrl    = TextEditingController(text: u?.email ?? '');
    _phoneCtrl    = TextEditingController(text: u?.phone ?? '');
    _ageCtrl      = TextEditingController(
        text: u != null && u.age > 0 ? '${u.age}' : '');
    _passwordCtrl = TextEditingController();
    _gender = (u?.gender.isNotEmpty == true) ? u!.gender : 'Nam';

    // Pre-validate existing data in edit mode
    if (widget.isEditMode) {
      _checkAll();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  String _firstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  String _lastName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  void _checkAll() {
    if (_firstNameCtrl.text.trim().isNotEmpty) _valid.add('firstName');
    if (_lastNameCtrl.text.trim().isNotEmpty) _valid.add('lastName');
    if (_usernameCtrl.text.trim().isNotEmpty) _valid.add('username');
    if (_isValidEmail(_emailCtrl.text.trim())) _valid.add('email');
    if (_phoneCtrl.text.trim().isNotEmpty) _valid.add('phone');
    if (int.tryParse(_ageCtrl.text.trim()) != null) _valid.add('age');
    if (widget.isEditMode || _passwordCtrl.text.length >= 6) _valid.add('password');
  }

  bool _isValidEmail(String s) =>
      RegExp(r'^[\w\-.]+@[\w\-.]+\.\w+$').hasMatch(s);

  void _onFieldChanged(String key, String value) {
    bool ok = false;
    switch (key) {
      case 'firstName': ok = value.trim().isNotEmpty; break;
      case 'lastName':  ok = value.trim().isNotEmpty; break;
      case 'username':  ok = value.trim().isNotEmpty; break;
      case 'email':     ok = _isValidEmail(value.trim()); break;
      case 'phone':     ok = value.trim().isNotEmpty; break;
      case 'age':       ok = int.tryParse(value.trim()) != null; break;
      case 'password':  ok = value.length >= 6; break;
    }
    setState(() {
      if (ok) { _valid.add(key); } else { _valid.remove(key); }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final vm = context.read<UserManagementViewModel>();
    final fullName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();

    if (widget.isEditMode) {
      final updated = widget.existingUser!.copyWith(
        fullName:  fullName,
        username:  _usernameCtrl.text.trim(),
        email:     _emailCtrl.text.trim(),
        phone:     _phoneCtrl.text.trim(),
        age:       int.tryParse(_ageCtrl.text.trim()) ?? 0,
        gender:    _gender,
        imageUrl:  _pickedImagePath ?? widget.existingUser!.imageUrl,
      );
      await vm.updateUser(updated);
    } else {
      final newUser = UserItem(
        id: 0,  // will be replaced in addUser
        fullName:  fullName,
        username:  _usernameCtrl.text.trim(),
        email:     _emailCtrl.text.trim(),
        imageUrl:  _pickedImagePath ?? '',
        phone:     _phoneCtrl.text.trim(),
        age:       int.tryParse(_ageCtrl.text.trim()) ?? 0,
        gender:    _gender,
        birthDate: '',
        address:   '',
      );
      await vm.addUser(newUser);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditMode
              ? 'Thêm / Cập nhật người dùng'
              : 'Thêm / Cập nhật người dùng',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Avatar picker ──────────────────────────────────────────
            _AvatarPicker(
              currentImageUrl: _pickedImagePath ?? widget.existingUser?.imageUrl,
              onTap: _pickImage,
            ),
            const SizedBox(height: 20),

            // ── Họ ────────────────────────────────────────────────────
            _FormLabel(label: 'Họ', required: true),
            _FormField(
              controller: _firstNameCtrl,
              hintText: 'Nguyễn',
              fieldKey: 'firstName',
              valid: _valid.contains('firstName'),
              onChanged: (v) => _onFieldChanged('firstName', v),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ' : null,
            ),
            const SizedBox(height: 14),

            // ── Tên ───────────────────────────────────────────────────
            _FormLabel(label: 'Tên', required: true),
            _FormField(
              controller: _lastNameCtrl,
              hintText: 'Văn An',
              fieldKey: 'lastName',
              valid: _valid.contains('lastName'),
              onChanged: (v) => _onFieldChanged('lastName', v),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 14),

            // ── Username ──────────────────────────────────────────────
            _FormLabel(label: 'Username', required: true),
            _FormField(
              controller: _usernameCtrl,
              hintText: 'nguyenvanan',
              fieldKey: 'username',
              valid: _valid.contains('username'),
              onChanged: (v) => _onFieldChanged('username', v),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập username'
                  : null,
            ),
            const SizedBox(height: 14),

            // ── Email ─────────────────────────────────────────────────
            _FormLabel(label: 'Email', required: true),
            _FormField(
              controller: _emailCtrl,
              hintText: 'nguyenvanan@example.com',
              fieldKey: 'email',
              keyboardType: TextInputType.emailAddress,
              valid: _valid.contains('email'),
              onChanged: (v) => _onFieldChanged('email', v),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                if (!_isValidEmail(v.trim())) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Số điện thoại ─────────────────────────────────────────
            _FormLabel(label: 'Số điện thoại', required: true),
            _FormField(
              controller: _phoneCtrl,
              hintText: '0965 123 456',
              fieldKey: 'phone',
              keyboardType: TextInputType.phone,
              valid: _valid.contains('phone'),
              onChanged: (v) => _onFieldChanged('phone', v),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập số điện thoại'
                  : null,
            ),
            const SizedBox(height: 14),

            // ── Tuổi + Giới tính (2 columns) ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tuổi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel(label: 'Tuổi', required: true),
                      _FormField(
                        controller: _ageCtrl,
                        hintText: '28',
                        fieldKey: 'age',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        valid: _valid.contains('age'),
                        onChanged: (v) => _onFieldChanged('age', v),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nhập tuổi';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0 || n > 120) {
                            return 'Không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Giới tính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel(label: 'Giới tính', required: true),
                      _GenderDropdown(
                        value: _gender,
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Mật khẩu ─────────────────────────────────────────────
            if (!widget.isEditMode) ...[
              _FormLabel(label: 'Mật khẩu', required: true),
              _PasswordField(
                controller: _passwordCtrl,
                obscure: _obscurePassword,
                valid: _valid.contains('password'),
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (v) => _onFieldChanged('password', v),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (v.length < 6) return null; // shown via hint below
                  return null;
                },
              ),
              // Password hint
              if (_passwordCtrl.text.isNotEmpty &&
                  _passwordCtrl.text.length < 6)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined,
                          color: _C.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Mật khẩu phải có ít nhất 6 ký tự.',
                        style: TextStyle(color: _C.green, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 10),

            // ── Buttons ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.textSecondary,
                      side: const BorderSide(color: _C.border),
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
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: _C.teal,
                      disabledBackgroundColor: _C.teal.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Avatar picker ─────────────────────────────────────────────────────────
class _AvatarPicker extends StatelessWidget {
  final String? currentImageUrl;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.currentImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(currentImageUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.tealLight,
                  image: imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null,
                  border: Border.all(
                      color: _C.teal.withValues(alpha: 0.3), width: 2),
                ),
                child: imageProvider == null
                    ? const Icon(
                        Icons.camera_alt_outlined,
                        color: _C.teal,
                        size: 36,
                      )
                    : null,
              ),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _C.green,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Chọn ảnh đại diện',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'JPG, PNG tối đa 2MB',
          style: TextStyle(fontSize: 12, color: _C.textSecondary),
        ),
      ],
    ),
  );
}
}

// ── Form label ────────────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FormLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _C.textPrimary),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: _C.error),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

// ── Generic form field ────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String fieldKey;
  final bool valid;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.controller,
    required this.hintText,
    required this.fieldKey,
    required this.valid,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _C.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            const TextStyle(color: _C.textHint, fontSize: 15),
        suffixIcon: valid
            ? const Icon(Icons.check, color: _C.green, size: 20)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.error, width: 1.5),
        ),
      ),
    );
  }
}

// ── Password field ────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool valid;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.valid,
    required this.onToggle,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _C.textPrimary),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: _C.textHint, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: _C.textSecondary,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            if (valid)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check, color: _C.green, size: 20),
              ),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.error, width: 1.5),
        ),
      ),
    );
  }
}

// ── Gender dropdown ───────────────────────────────────────────────────────
class _GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _C.borderFocus, width: 1.5),
        ),
      ),
      style: const TextStyle(fontSize: 15, color: _C.textPrimary),
      items: const [
        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
      ],
    );
  }
}
