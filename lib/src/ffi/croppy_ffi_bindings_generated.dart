// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Bindings for `src/croppy_ffi.h`.
///
/// Regenerate bindings with `flutter pub run ffigen --config ffigen.yaml`.
///
class CroppyFfiBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  CroppyFfiBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  CroppyFfiBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  Aabb2 fit_polygon_in_quad(
    ffi.Pointer<ffi.Double> points,
    int length,
  ) {
    return _fit_polygon_in_quad(
      points,
      length,
    );
  }

  late final _fit_polygon_in_quadPtr = _lookup<
          ffi.NativeFunction<Aabb2 Function(ffi.Pointer<ffi.Double>, ffi.Int)>>(
      'fit_polygon_in_quad');
  late final _fit_polygon_in_quad = _fit_polygon_in_quadPtr
      .asFunction<Aabb2 Function(ffi.Pointer<ffi.Double>, int)>(isLeaf: true);
}

final class Vector2 extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;
}

final class Aabb2 extends ffi.Struct {
  external Vector2 min;

  external Vector2 max;
}