import 'package:flutter/material.dart';
import 'package:qnotes/constants/routes.dart';
import 'package:qnotes/services/auth/auth_exceptions.dart';
import 'package:qnotes/services/auth/auth_service.dart';
import 'package:qnotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'Enter your email here'),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: 'Enter your password here'),
                    ),
                    TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;

                          try {
                            await AuthService.firebase()
                                .createUser(email: email, password: password);

                            await AuthService.firebase()
                                .sendEmailVerification();
                            if (!mounted) return;
                            Navigator.of(context).pushNamed(verifyEmailRoute);
                          } on EmailAlreadyInUseAuthException {
                            await showErrorDialog(
                              context,
                              'Email already in use',
                            );
                          } on WeakPasswordAuthException {
                            await showErrorDialog(
                              context,
                              'Weak password',
                            );
                          } on InvaidEmailAuthException {
                            await showErrorDialog(
                              context,
                              'Invalid email',
                            );
                          } on GenericAuthException {
                            await showErrorDialog(
                              context,
                              'Registration failed',
                            );
                          }
                        },
                        child: const Text('Register')),
                    TextButton(
                        onPressed: () async {
                          await Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (route) => false);
                        },
                        child: const Text('Already registered? Login here!'))
                  ],
                );

              default:
                return const Text('Loading...');
            }
          },
        ));
  }
}
