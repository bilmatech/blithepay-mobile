import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AppLocalDataSource localDataSource;
  final AuthRepository authRepository;

  ProfileBloc(this.localDataSource, this.authRepository)
    : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ChangePinRequested>(_onChangePinRequested);
    on<DeleteAccount>(_onDeleteAccount);
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
      final updatedUser = await authRepository.updateAccount(
        fullName: event.name,
        phoneNumber: event.phone,
      );
      await localDataSource.updateSessionUser(updatedUser);

      emit(const ProfileUpdated());

      // Optional: reload fresh profile
      add(const GetProfileEvent());
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

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      await authRepository.deleteAccount();

      await localDataSource.clearSession(); // ✅ clear session here

      emit(const ProfileDeleted());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onChangePinRequested(
    ChangePinRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await authRepository.changeAppPin(event.oldPin, event.newPin, event.password);
      emit(const ProfilePinChanged(message: 'App PIN changed successfully.'));
    } catch (e) {
      emit(ProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
