import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lpdr_mobile/services/authService.dart'; // Import your AuthService class here
import 'package:lpdr_mobile/util/HttpRequest.dart';

// Create a mock for the HttpRequest class
class MockHttpRequest extends Mock implements HttpRequest {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockHttpRequest mockHttpRequest;

    setUp(() {
      authService = AuthService();
      mockHttpRequest = MockHttpRequest();
    });

    test('login should make a POST request and return a response', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password';
      final expectedResponse = Response('{"token": "your_token_here"}', 200);

      when(() => mockHttpRequest.post(any(), any())).thenAnswer(
        (_) async => expectedResponse,
      );

      // Act
      final response = await authService.login(email, password);

      // Assert
      expect(response, equals(expectedResponse));
      verify(() => mockHttpRequest.post(any(), any())).called(1);
    });

    test('signup should make a POST request and return a response', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password';
      final expectedResponse = Response('{"message": "Account created"}', 201);
      when(() => mockHttpRequest.post(any(), any())).thenAnswer(
        (_) async => expectedResponse,
      );

      // Act
      final response = await authService.signup(email, password);

      // Assert
      expect(response, equals(expectedResponse));
      verify(() => mockHttpRequest.post(any(), any())).called(1);
    });
  });
}
