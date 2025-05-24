import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart';

/// Injects the library by its [url]
Future<void> inject(String url) async {
  print('a');
  if (_isImported(url)) {
    return;
  }

  final head = document.querySelector('head')!;
  final scriptTag = _createScriptTag(url);
  head.appendChild(scriptTag);
  await scriptTag.onLoad.first;
}

bool _isImported(String url) {
  if (url.startsWith("./")) {
    url = url.replaceFirst("./", "");
  }

  final head = document.querySelector('head')!;
  for (var i = 0; i < head.children.length; i++) {
    final element = head.children.item(i);
    if (element.isA<HTMLScriptElement>() &&
        (element as HTMLScriptElement).src.endsWith(url)) {
      return true;
    }
  }
  return false;
}

HTMLScriptElement _createScriptTag(String library) {
  final HTMLScriptElement script = HTMLScriptElement()
    ..type = "text/javascript"
    ..charset = "utf-8"
    ..async = true
    ..src = library;
  return script;
}
