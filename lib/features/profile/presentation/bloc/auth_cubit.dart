import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<void> {
  final AppLocalDataSource _localDataSource;

  AuthCubit(this._localDataSource) : super(null);

  Future<void> logout() async {
    await _localDataSource.clearSession();
  }
}
