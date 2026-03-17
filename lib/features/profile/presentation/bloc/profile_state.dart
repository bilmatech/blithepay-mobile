abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Map<String, String> profile;
  const ProfileLoaded({required this.profile});
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated();
}

class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}
