import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/services/auth/auth_service.dart';
import 'package:learning/services/auth/bloc/auth_bloc.dart';
import 'package:learning/services/auth/bloc/auth_event.dart';
import 'package:learning/services/auth/bloc/auth_state.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User Not Found');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong Credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: AuthService.firebase().initialize(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Column(
                    children: [
                      const Text('Please Log in to use the note app'),
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(hintText: "Enter Email"),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration:
                            const InputDecoration(hintText: "Enter Password"),
                      ),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          context.read<AuthBloc>().add(AuthEventLogIn(
                                email,
                                password,
                              ));
                        },
                        child: const Text("Login"),
                      ),
                      TextButton(
                        onPressed: () async {
                          context.read<AuthBloc>().add(const AuthEventForgotPassword());
                        },
                        child: const Text("Forgot Password"),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventShouldRegister());
                        },
                        child: const Text('Not registered yet? Register Here.'),
                      ),
                    ],
                  );
                default:
                  return const Text("Loading ...");
              }
            },
          ),
        ),
      ),
    );
  }
}
