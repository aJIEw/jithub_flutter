import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/http/http_transformer.dart';

void main() {
  group('GraphqlHttpTransformer', () {
    test('unwraps data from successful responses', () {
      final transformer = GraphqlHttpTransformer.getInstance();
      final response = Response<Map<String, dynamic>>(
        data: <String, dynamic>{
          'data': <String, dynamic>{
            'viewer': <String, dynamic>{'login': 'octocat'},
          },
        },
        requestOptions: RequestOptions(path: '/graphql'),
        statusCode: 200,
      );

      final result = transformer.parse(response);

      expect(result.ok, isTrue);
      expect(result.code, 200);
      expect(result.data, <String, dynamic>{
        'viewer': <String, dynamic>{'login': 'octocat'},
      });
    });

    test('treats GraphQL errors as request failures', () {
      final transformer = GraphqlHttpTransformer.getInstance();
      final response = Response<Map<String, dynamic>>(
        data: <String, dynamic>{
          'errors': <Map<String, dynamic>>[
            <String, dynamic>{'message': 'Bad credentials'},
          ],
        },
        requestOptions: RequestOptions(path: '/graphql'),
        statusCode: 200,
      );

      final result = transformer.parse(response);

      expect(result.ok, isFalse);
      expect(result.code, 200);
      expect(result.error?.message, 'Bad credentials');
    });

    test('rejects malformed responses', () {
      final transformer = GraphqlHttpTransformer.getInstance();
      final response = Response<List<String>>(
        data: const <String>['unexpected'],
        requestOptions: RequestOptions(path: '/graphql'),
        statusCode: 200,
      );

      final result = transformer.parse(response);

      expect(result.ok, isFalse);
      expect(result.error?.message, 'Invalid GraphQL response');
    });
  });
}
