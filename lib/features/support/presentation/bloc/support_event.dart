import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends SupportEvent {
  final String name;
  final String email;
  final String message;

  const SendMessageEvent({
    required this.name,
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [name, email, message];
}
