import 'package:flutter/material.dart';
import '../utils/navigation_helper.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // จำลองการส่งลิงก์รีเซ็ตรหัสผ่าน
  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // จำลองการเรียก API
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _emailSent = true;
      });

      NavigationHelper.showSuccessSnackBar(
        'ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว',
      );
    } catch (e) {
      NavigationHelper.showErrorSnackBar(
        'ไม่สามารถส่งลิงก์รีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // รีเซ็ตสถานะเพื่อส่งอีเมลใหม่
  void _resetForm() {
    setState(() {
      _emailSent = false;
      _emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC6D2FC), // Light purple-blue
              Color(0xFF9A93BD), // Medium purple
              Color(0xFFF2B1DB), // Light pink
              Color(0xFFFDC2B4), // Light peach
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => NavigationHelper.back(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: _emailSent 
                                    ? const Color(0xFFC6D2FC).withOpacity(0.2)
                                    : const Color(0xFFF2B1DB).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                                size: 50,
                                color: _emailSent 
                                    ? const Color(0xFF9A93BD)
                                    : const Color(0xFFF2B1DB),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Title and Description
                            if (!_emailSent) ...[
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'Enter your email address and we\'ll send you a link to reset your password',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Email Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EMAIL ADDRESS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'you@example.com',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        suffixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'กรุณากรอกอีเมล';
                                        }
                                        if (!value.contains('@') || !value.contains('.')) {
                                          return 'กรุณากรอกอีเมลให้ถูกต้อง';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Send Reset Link Button
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF2B1DB),
                                      Color(0xFFC6D2FC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSendResetLink,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Send Reset Link',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ] else ...[
                              // Success State
                              Text(
                                'Email Sent!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF9A93BD),
                                ),
                              ),

                              const SizedBox(height: 16),

                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'We\'ve sent a password reset link to\n',
                                    ),
                                    TextSpan(
                                      text: _emailController.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9A93BD),
                                      ),
                                    ),
                                    const TextSpan(text: '\n\nPlease check your email'),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Resend Button
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF9A93BD),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: _resetForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Resend Email',
                                    style: TextStyle(
                                      color: Color(0xFF9A93BD),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Navigation Links
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Remember your password? ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => NavigationHelper.toLogin(),
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.pink[300],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Don\'t have an account? ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => NavigationHelper.toRegister(),
                                      child: Text(
                                        'Create Account',
                                        style: TextStyle(
                                          color: Colors.pink[300],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Help Text
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC6D2FC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFC6D2FC).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: const Color(0xFF9A93BD),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Can\'t find the email?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF9A93BD),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Check your spam or junk folder\n'
                                    '• Make sure the email address is correct\n'
                                    '• It may take 2-3 minutes to receive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF9A93BD),
                                      height: 1.4,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}