import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/services/auth/auth_provider.dart';
import 'package:learning/services/auth/bloc/auth_event.dart';
import 'package:learning/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    //initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(null));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );

    //logIn
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoading());
      final email=event.email;
      final password=event.password;
      try{
        final user=await provider.logIn(email: email, password: password,);
        emit(AuthStateLoggedIn(user));
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(e));
      }
    },);

    //logOut
    on<AuthEventLogOut>((event, emit) async {
      try{
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut(null));
      }
      on Exception catch(e){
        emit(AuthStateLogOutFailure(e));
      }
    },);
  }
}
