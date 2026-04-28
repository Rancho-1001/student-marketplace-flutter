import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../services/auth_service.dart';

enum AuthMode { createAccount, signIn }

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    required this.onAuthenticated,
  });

  final AuthService authService;
  final void Function(AuthSession session) onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController(text: 'lemuel');
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  AuthMode mode = AuthMode.createAccount;
  String campus = campuses.first;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isSubmitting = false;

  bool get isCreateAccount => mode == AuthMode.createAccount;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isSubmitting = true);
      try {
        final username = usernameController.text.trim();
        final password = passwordController.text;
        final session = isCreateAccount
            ? await widget.authService.createAccount(
                username: username,
                password: password,
                campus: campus,
              )
            : await widget.authService.signIn(
                username: username,
                password: password,
                campus: campus,
              );
        widget.onAuthenticated(session);
      } catch (error) {
        showAuthError(error);
      } finally {
        if (mounted) {
          setState(() => isSubmitting = false);
        }
      }
    }
  }

  Future<void> continueWithGoogle() async {
    setState(() => isSubmitting = true);
    try {
      final session = await widget.authService.signInWithGoogle(campus: campus);
      widget.onAuthenticated(session);
    } catch (error) {
      showAuthError(error);
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void showAuthError(Object error) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
  }

  String authErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('email-already-in-use')) {
      return 'That username is already taken.';
    }
    if (message.contains('operation-not-allowed')) {
      return 'This sign-in method is disabled in Firebase Console.';
    }
    if (message.contains('permission-denied')) {
      return 'Firebase blocked profile access. Check Firestore rules.';
    }
    if (message.contains('not-found') && message.contains('Firestore')) {
      return 'Firestore is not created yet in Firebase Console.';
    }
    if (message.contains('network-request-failed')) {
      return 'Network error. Check your connection and try again.';
    }
    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Username or password is incorrect.';
    }
    if (message.contains('popup-closed-by-user') ||
        message.contains('canceled')) {
      return 'Sign in was canceled.';
    }
    return 'Authentication failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroPanel(colorScheme: colorScheme),
                  const SizedBox(height: 18),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isCreateAccount
                                  ? 'Create your account'
                                  : 'Welcome back',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isCreateAccount
                                  ? 'Use a username and password, or continue with Google.'
                                  : 'Sign in with your username and password, or use Google.',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.62),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SegmentedButton<AuthMode>(
                              segments: const [
                                ButtonSegment(
                                  value: AuthMode.createAccount,
                                  icon: Icon(Icons.person_add_alt_1),
                                  label: Text('Create'),
                                ),
                                ButtonSegment(
                                  value: AuthMode.signIn,
                                  icon: Icon(Icons.login),
                                  label: Text('Login'),
                                ),
                              ],
                              selected: {mode},
                              showSelectedIcon: false,
                              onSelectionChanged: (selection) {
                                setState(() {
                                  mode = selection.first;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: validateUsername,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: validatePassword,
                            ),
                            if (isCreateAccount) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirm password',
                                  prefixIcon: const Icon(Icons.lock_reset),
                                  suffixIcon: IconButton(
                                    tooltip: obscureConfirmPassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () {
                                      setState(() {
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: validateConfirmPassword,
                              ),
                            ],
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: campus,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Campus',
                                prefixIcon: Icon(Icons.school_outlined),
                              ),
                              items: campuses
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => campus = value);
                                }
                              },
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: isSubmitting ? null : submit,
                              icon: Icon(
                                isCreateAccount
                                    ? Icons.person_add_alt_1
                                    : Icons.login,
                              ),
                              label: Text(
                                isCreateAccount ? 'Create Account' : 'Log In',
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _DividerLabel(label: 'or'),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : continueWithGoogle,
                              icon: const Icon(Icons.g_mobiledata, size: 30),
                              label: const Text('Continue with Google'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Firebase Auth is connected. Enable Email/Password, Google, and Firestore in Firebase Console before testing.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) {
      return 'Enter a username';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (!isCreateAccount) {
      return null;
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 28),
          Text(
            'Student Marketplace',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A cleaner way to buy, sell, and trade campus essentials with students nearby.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
