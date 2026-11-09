import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/extension/string.dart';

void main() {
  group('StringExtension.githubAvatarAtSize', () {
    test('raises the s parameter and keeps other query parameters', () {
      const String url =
          'https://avatars.githubusercontent.com/u/122662504?s=40&v=4';

      final Uri result = Uri.parse(url.githubAvatarAtSize(200));

      expect(result.host, 'avatars.githubusercontent.com');
      expect(result.path, '/u/122662504');
      expect(result.queryParameters['s'], '200');
      expect(result.queryParameters['v'], '4');
    });

    test('leaves non-avatar GitHub URLs unchanged', () {
      const String url = 'https://github.com/anthropics/skills';

      expect(url.githubAvatarAtSize(200), url);
    });

    test('leaves GitHub avatar URLs without an s parameter unchanged', () {
      const String url = 'https://avatars.githubusercontent.com/u/583231?v=4';

      expect(url.githubAvatarAtSize(200), url);
    });

    test('leaves empty and malformed strings unchanged', () {
      expect(''.githubAvatarAtSize(200), '');
      expect('not a url'.githubAvatarAtSize(200), 'not a url');
    });

    test('leaves the URL unchanged when size is not positive', () {
      const String url =
          'https://avatars.githubusercontent.com/u/122662504?s=40&v=4';

      expect(url.githubAvatarAtSize(0), url);
    });
  });
}
