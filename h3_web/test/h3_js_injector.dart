import 'dart:async';
import 'dart:html' as html;

/// Injects the library by its [url]
Future<void> inject(String url) async {
  final head = html.querySelector('head');

  if (!_isImported(url)) {
    final scriptTag = _createScriptTag(url);
    head!.children.add(scriptTag);
    await scriptTag.onLoad.first;
  }
}

bool _isImported(String url) {
  final head = html.querySelector('head');
  if (url.startsWith("./")) {
    url = url.replaceFirst("./", "");
  }
  for (var element in head!.children) {
    if (element is html.ScriptElement) {
      if (element.src.endsWith(url)) {
        return true;
      }
    }
  }
  return false;
}

html.ScriptElement _createScriptTag(String library) {
  final html.ScriptElement script = html.ScriptElement()
    ..type = "text/javascript"
    ..charset = "utf-8"
    ..async = true
    ..src = library;
  return script;
}
