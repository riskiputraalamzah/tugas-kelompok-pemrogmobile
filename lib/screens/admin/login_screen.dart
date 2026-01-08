import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../config/theme.dart';
import 'dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final success = await provider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(provider.error ?? 'Login gagal'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            message: 'Memverifikasi...',
            child: child!,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Admin Portal',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 44), // Balance
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Logo and title
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Selamat Datang',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk untuk mengelola sistem rekrutmen',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Login form container
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Drag handle
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: AppTheme.shimmerColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                
                                Text(
                                  'Login',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Masukkan kredensial Anda untuk melanjutkan',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subtitleColor,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                CustomTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  hint: 'Masukkan username',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username harus diisi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Masukkan password',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password harus diisi';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Login button with gradient
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.login_rounded, color: Colors.white),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Masuk',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Demo credentials
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withValues(alpha: 0.08),
                                        AppTheme.primaryColor.withValues(alpha: 0.04),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.lightbulb_outline_rounded,
                                          color: AppTheme.primaryColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Demo Credentials',
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Username: admin • Password: admin123',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.subtitleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
