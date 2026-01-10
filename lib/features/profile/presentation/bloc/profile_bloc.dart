import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(
        const ProfileLoaded(
          profile: {
            'name': 'Abdul Yusuf Gafar',
            'phone': '+2347098765432',
            'email': 'Abdulyu sufgafar@gmail.com',
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
}
