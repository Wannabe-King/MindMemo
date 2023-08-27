import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/services/auth/auth_exceptions.dart';
import 'package:learning/services/auth/auth_service.dart';
import 'package:learning/services/auth/bloc/auth_bloc.dart';
import 'package:learning/services/auth/bloc/auth_event.dart';
import 'package:learning/services/auth/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password!!!');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email Already Registered');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: AuthService.firebase().initialize(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Please enter email and password to create an account in our app'),
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: true,
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
                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                context.read<AuthBloc>().add(AuthEventRegister(
                                      email,
                                      password,
                                    ));
                              },
                              child: const Text("Register Button"),
                            ),
                            TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthEventLogOut());
                            },
                            child: const Text('Already Registerd ? Login Here.'))
                          ],
                        ),
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
