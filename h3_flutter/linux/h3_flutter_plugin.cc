#include "include/h3_flutter/h3_flutter_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define H3_FLUTTER_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), h3_flutter_plugin_get_type(), \
                              H3FlutterPlugin))

struct _H3FlutterPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(H3FlutterPlugin, h3_flutter_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void h3_flutter_plugin_handle_method_call(
    H3FlutterPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());

  fl_method_call_respond(method_call, response, nullptr);
}

static void h3_flutter_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(h3_flutter_plugin_parent_class)->dispose(object);
}

static void h3_flutter_plugin_class_init(H3FlutterPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = h3_flutter_plugin_dispose;
}

static void h3_flutter_plugin_init(H3FlutterPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  H3FlutterPlugin* plugin = H3_FLUTTER_PLUGIN(user_data);
  h3_flutter_plugin_handle_method_call(plugin, method_call);
}

void h3_flutter_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  H3FlutterPlugin* plugin = H3_FLUTTER_PLUGIN(
      g_object_new(h3_flutter_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "h3_flutter",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
