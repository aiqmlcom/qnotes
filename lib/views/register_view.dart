import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qnotes/constants/routes.dart';
import 'package:qnotes/firebase_options.dart';
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
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
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
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email, password: password);
                          } on FirebaseAuthException catch (e) {
                            switch (e.code) {
                              case 'email-already-in-use':
                                await showErrorDialog(
                                  context,
                                  'Email already in use',
                                );
                                break;
                              case 'weak-password':
                                await showErrorDialog(
                                  context,
                                  'Weak password',
                                );
                                break;
                              case 'invalid-email':
                                await showErrorDialog(
                                  context,
                                  'Invalid email',
                                );
                                break;
                              default:
                                await showErrorDialog(
                                  context,
                                  'Error ${e.code}',
                                );
                                break;
                            }
                          } catch (e) {
                            await showErrorDialog(
                              context,
                              e.toString(),
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
