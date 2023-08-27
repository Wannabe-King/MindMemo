import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/constants/routes.dart';
import 'package:learning/helper/loading/loading_screen.dart';
import 'package:learning/services/auth/bloc/auth_bloc.dart';
import 'package:learning/services/auth/bloc/auth_event.dart';
import 'package:learning/services/auth/bloc/auth_state.dart';
import 'package:learning/services/auth/firebase_auth_provider.dart';
import 'package:learning/views/forgot_password_view.dart';
import 'package:learning/views/login_view.dart';
import 'package:learning/views/notes/create_update_notes_view.dart';
import 'package:learning/views/notes/notes_view.dart';
import 'package:learning/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

//use stl shorthand
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        }
        else{
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } 
        else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } 
        else if(state is AuthStateForgotPassword){
          return const ForgotPasswordView();
        } 
        else if (state is AuthStateRegistering) {
          return const RegisterView();
        } 
        else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}




//     return FutureBuilder(
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = AuthService.firebase().currentUser;
//             if (user != null) {
//               if (user.isEmailVerified) {
//                 return const NotesView();
//               } else {
//                 return const VerfiyEmailView();
//               }
//             } else {
//               return const LoginView();
//             }
//           default:
//             return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Testing Bloc'),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           listener: (context, state) {
//             _controller.clear();
//           },
//           builder: (context, state) {
//             final invalidValue =
//                 (state is CounterStateInvalidNumber) ? state.invalidValue : '';
//             return Column(
//               children: [
//                 Text('Current Value is ${state.value}'),
//                 Visibility(
//                   visible: state is CounterStateInvalidNumber,
//                   child: Text('Invalid input: $invalidValue'),
//                 ),
//                 TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter a number here',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 Row(
//                   children: [
//                     TextButton(onPressed: (){
//                       context.read<CounterBloc>()
//                       .add(DecrementEvents(_controller.text));
//                     }, child: const Text('-'))
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     TextButton(onPressed: (){
//                       context.read<CounterBloc>()
//                       .add(IncrementEvents(_controller.text));
//                     }, child: const Text('+'))
//                   ],
//                 )
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;
//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }

// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvents extends CounterEvent {
//   const IncrementEvents(String value) : super(value);
// }

// class DecrementEvents extends CounterEvent {
//   const DecrementEvents(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvents>(((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(
//           state.value + integer,
//         ));
//       }
//     }));
//     on<DecrementEvents>(((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(
//           state.value - integer,
//         ));
//       }
//     }));
//   }
// }
