import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(const SupportInitial()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<SupportState> emit) async {
    try {
      emit(const SupportLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(const MessageSent('Your message has been sent successfully'));
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }
}
