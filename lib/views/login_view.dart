import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/constants/routes.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
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
                    decoration: const InputDecoration(hintText: "Enter Email"),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: "Enter Password"),
                  ),
                  BlocListener<AuthBloc,AuthState>(
                    listener: (context, state) async {
                      if(state is AuthStateLoggedOut){
                        if(state.exception is UserNotFoundAuthException){
                          await showErrorDialog(context,'User Not Found');
                        }
                        else if(state.exception is WrongPasswordAuthException){
                          await showErrorDialog(context,'Wrong Credentials');
                        }
                        else if(state.exception is GenericAuthException){
                          await showErrorDialog(context,'Authentication Error');
                        }
                      }
                    },
                    child: TextButton(
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
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                      );
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
    );
  }
}
