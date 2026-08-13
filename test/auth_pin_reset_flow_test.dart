import 'package:flutter_test/flutter_test.dart';
import 'package:blithepay/core/network/api_endpoints.dart';

void main() {
  test('PIN reset endpoints match the new protected API contract', () {
    expect(ApiEndpoints.pinInitiateReset, '/auth/pin/initiate_reset');
    expect(ApiEndpoints.pinReset, '/auth/pin/reset');
  });
}
