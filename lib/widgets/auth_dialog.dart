import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Dialog pour se connecter ou créer un compte
class AuthDialog extends StatefulWidget {
  final bool isSignup;

  const AuthDialog({
    super.key,
    this.isSignup = false,
  });

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignup = widget.isSignup;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    bool success = await authService.loginOrSignup(
      username,
      password,
      isSignup: _isSignup,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true); // Succès
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = _isSignup
              ? 'Ce nom d\'utilisateur est déjà pris'
              : 'Identifiants incorrects';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              Text(
                _isSignup ? 'Créer un compte' : 'Se connecter',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B4423),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isSignup
                    ? 'Choisissez un nom d\'utilisateur unique'
                    : 'Entrez votre nom d\'utilisateur',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Champ username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  if (value.trim().length < 3) {
                    return 'Minimum 3 caractères';
                  }
                  return null;
                },
                enabled: !_isLoading,
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Champ mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _errorMessage,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (_isSignup && value.length < 6) {
                    return 'Minimum 6 caractères';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Bouton principal
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4423),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isSignup ? 'Créer le compte' : 'Se connecter'),
              ),
              const SizedBox(height: 16),

              // Toggle entre login/signup
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isSignup = !_isSignup;
                          _errorMessage = null;
                        });
                      },
                child: Text(
                  _isSignup
                      ? 'Déjà un compte ? Se connecter'
                      : 'Pas de compte ? S\'inscrire',
                  style: const TextStyle(color: Color(0xFF6B4423)),
                ),
              ),

              // Bouton annuler
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
