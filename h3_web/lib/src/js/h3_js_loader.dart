import 'dart:async';

import 'package:h3_web/src/js/h3_js.dart';
import 'package:web/web.dart' as web;

Future<void>? _loading;

/// Loads h3-js by adding a script tag to the page, unless h3-js is already
/// loaded. Concurrent calls share one request.
///
/// Throws a [StateError] when the script cannot be loaded.
Future<void> ensureH3JsLoaded({String? url}) {
  if (isH3JsLoadedOnPage) return Future.value();
  return _loading ??= _load(url ?? defaultH3JsUrl).whenComplete(() {
    _loading = null;
  });
}

Future<void> _load(String url) async {
  final script = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..charset = 'utf-8'
    ..src = url;
  final loaded = script.onLoad.first.then((_) => true);
  final failed = script.onError.first.then((_) => false);
  web.document.head!.appendChild(script);

  if (!await Future.any([loaded, failed])) {
    script.remove();
    throw StateError('Failed to load h3-js from $url');
  }
  if (!isH3JsLoadedOnPage) {
    throw StateError(
      'The script at $url was loaded, but it did not define the global h3',
    );
  }
}
