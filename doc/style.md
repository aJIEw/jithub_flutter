# Dart Style Guide

Follow [Effective Dart: Style](https://dart.dev/effective-dart/style).
This file keeps only the rules we use often in this project.

## Core Rules

- Run `dart format` on every change.
- Prefer lines of 80 characters or fewer.
- Always use braces for `if`, `for`, `while`, and `switch` branches.
- Use trailing commas to help the formatter split long widget trees and
  argument lists.

## Naming

- Types, enums, extensions, and typedefs use `UpperCamelCase`.
- Variables, methods, parameters, and fields use `lowerCamelCase`.
- Files and directories use `lowercase_with_underscores`.
- Constants prefer `lowerCamelCase`, not screaming snake case.
- Acronyms longer than two letters are treated like normal words:
  `HttpClient`, `GithubUser`, `userId`.
- Do not add meaningless prefixes such as `m`, `s`, `k`, or `str`.

## Imports

- Use `dart:` imports first, then `package:` imports.
- Sort each import section alphabetically.
- Prefer `package:` imports inside this app. Avoid leading `/` imports and
  avoid mixing multiple import styles in the same file.
- Put `export` directives in their own section after imports.

## Variables And Types

- Prefer `final` for locals and fields that are not reassigned.
- Use `const` for compile-time constants and immutable widget literals when
  possible.
- Avoid `var` when the type is unclear or when `final` is more precise.
- Avoid `dynamic` unless there is no reasonable static type.
- Prefer specific return types such as `Future<void>`,
  `Future<List<String>>`, and `ValueChanged<String>` over broad types like
  `Future`, `List`, `Object`, or `Function`.
- Use specific `List` and `Map` types when the element type matters. Avoid
  untyped empty collections like `[]` or `{}`. Prefer `const <String>[]` or
  `<String, dynamic>{}`.

## Functions And Callbacks

- Keep short expressions short, but do not force `=>` when it breaks wrapping or
  readability.
- Use positional parameters for required values and named parameters for
  optional values.
- Prefer explicit callback types such as `VoidCallback`,
  `ValueChanged<T>`, or `Widget Function(T)` instead of `Function`.
- Use `_` for intentionally unused callback parameters.

## Flutter-Specific

- Prefer `super.key` in widget constructors.
- Mark widgets and values `const` whenever possible.
- Keep build methods readable: when a block becomes hard to scan, extract it
  into a widget instead of a helper method when possible. This improves widget reusability
  and reduces unnecessary rebuild.
- Prefer clear, typed state over loosely typed controller fields.

## Collection And String Style

- Prefer `isEmpty` and `isNotEmpty` over length comparisons.
- Prefer interpolation over manual concatenation.
- Use single quotes unless double quotes improve readability by avoiding
  escaping.

## Project Notes

- Keep view models and controllers strongly typed. Avoid broad APIs such as
  `Future<List>` when the concrete model type is known.
- For refresh and list pages, preserve element types all the way through the
  base class and subclass chain.
- For UI helpers and dialogs, prefer typed callbacks and typed payloads over
  generic `Function` arguments.
- When adding new files, match the existing folder structure and naming style
  before introducing new patterns.
