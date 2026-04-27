import 'package:flutter/material.dart';

import '../models/listing.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onContinue});

  final void Function(String name, String campus) onContinue;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: 'Lemuel');
  String campus = campuses.first;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void submit() {
    if (formKey.currentState?.validate() ?? false) {
      widget.onContinue(nameController.text.trim(), campus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Student Marketplace',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buy and sell campus essentials with students nearby.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: submit,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
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
