#ifndef FLUTTER_PLUGIN_H3_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_H3_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace h3_flutter {

class H3FlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  H3FlutterPlugin();

  virtual ~H3FlutterPlugin();

  // Disallow copy and assign.
  H3FlutterPlugin(const H3FlutterPlugin&) = delete;
  H3FlutterPlugin& operator=(const H3FlutterPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace h3_flutter

#endif  // FLUTTER_PLUGIN_H3_FLUTTER_PLUGIN_H_
