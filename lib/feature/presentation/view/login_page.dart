import 'package:flutter/material.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/login_view_model.dart';
import 'package:provider/provider.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'emilys');

  final TextEditingController _passwordController =
      TextEditingController(text: 'emilyspass');

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final viewModel = context.read<LoginViewModel>();

    final success = await viewModel.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushReplacementNamed(
        context,
         AppRoutes.home,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đăng nhập',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Flutter MVVM - Auth Module',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _usernameController,
                        enabled: !viewModel.isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
controller: _passwordController,
                        enabled: !viewModel.isLoading,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.password_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (viewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      FilledButton(
                        onPressed:
                            viewModel.isLoading ? null : _submitLogin,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tài khoản demo: emilys / emilyspass',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
),
          ),
        ),
      ),
    );
  }
}


