import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AppLocalDataSource localDataSource;

  ProfileBloc(this.localDataSource) : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final session = await localDataSource.getSession();

      if (session == null || session.user == null) {
        emit(const ProfileError(message: 'User session not found'));
        return;
      }

      final user = session.user!;

      emit(
        ProfileLoaded(
          profile: {
            'name': '${user.firstName} ${user.lastName}',
            'phone': user.phone ?? '',
            'email': user.email ?? '',
          },
        ),
      );
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const ProfileUpdated());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // await _authRepository.resetPassword(
      //   event.oldPassword,
      //   event.newPassword,
      // );
      //  emit(const AuthState.passwordReset());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
