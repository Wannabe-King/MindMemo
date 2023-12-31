import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/services/auth/bloc/auth_bloc.dart';
import 'package:learning/services/auth/bloc/auth_event.dart';

class VerfiyEmailView extends StatefulWidget {
  const VerfiyEmailView({super.key});

  @override
  State<VerfiyEmailView> createState() => _VerfiyEmailViewState();
}

class _VerfiyEmailViewState extends State<VerfiyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text(
              "We've sent a verification link on your email. Please Verify."),
          const Text(
              "If you haven't recieved email form us.Please press the button below!"),
          TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
              },
              child: const Text('Send Email Verification')),
          TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text('Reset'))
        ],
      ),
    );
  }
}
