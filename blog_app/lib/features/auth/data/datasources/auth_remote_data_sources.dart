import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSources {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourcesImpl implements AuthRemoteDataSources {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourcesImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerExceptions('User is null!');
      }

      return UserModel.fromJson(
        response.user!.toJson(),
      ).copyWith(email: currentUserSession!.user.email);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user == null) {
        throw const ServerExceptions('User is null!');
      }

      return UserModel.fromJson(
        response.user!.toJson(),
      ).copyWith(email: currentUserSession!.user.email);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id);

        return UserModel.fromJson(
          userData.first,
        ).copyWith(email: currentUserSession!.user.email);
      }

      return null;
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }
}
