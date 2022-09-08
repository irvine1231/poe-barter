//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <keyboard_event/keyboard_event_plugin.h>
#include <sentry_flutter/sentry_flutter_plugin.h>
#include <window_size/window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  KeyboardEventPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("KeyboardEventPlugin"));
  SentryFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SentryFlutterPlugin"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
