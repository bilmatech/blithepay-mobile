abstract class ProfileEvent {
  const ProfileEvent();
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

// class UpdateProfileEvent extends ProfileEvent {
//   final Map<String, String> profileData;
//   const UpdateProfileEvent({required this.profileData});
// }

class ChangePasswordRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

class DeleteAccount extends ProfileEvent {
  const DeleteAccount();
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String phone;
  final String? gender;
  final String? profileImagePath;

  const UpdateProfileEvent({
    required this.name,
    required this.phone,
    this.gender,
    this.profileImagePath,
  });
}
