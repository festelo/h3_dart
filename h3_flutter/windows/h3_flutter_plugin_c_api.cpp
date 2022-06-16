#include "include/h3_flutter/h3_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "h3_flutter_plugin.h"

void H3FlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  h3_flutter::H3FlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
