# Target Host Contract

Status: normative for AiVectra target adapters.

AiVectra applications share one semantic application model across every target.
Target adapters are mechanical host integrations and must not define application,
UI, event, or state-transition semantics.

Each supported target adapter must implement these operations:

1. `prepare`: create the target-native runnable layout and include only required
   runtime, application, asset, and metadata files.
2. `validate`: reject missing executables, invalid metadata, incompatible
   architectures, unresolved runtime files, and invalid signatures before launch.
3. `launch`: start the target through its native application lifecycle rather
   than treating a GUI application as an ordinary command-line process.
4. `wait`: keep `ailang run` attached until the application exits or the caller
   explicitly requests a detached launch.
5. `diagnose`: return a non-zero result and actionable target-native diagnostics
   when preparation, validation, launch, or early application startup fails.

The same compiled AiLang application and `std-app` lifecycle semantics must be
usable by desktop, mobile, browser, and future target adapters. Adapters may
translate native lifecycle and input events into AiVectra events, but observable
state changes remain governed by deterministic queue dispatch.

Initial adapter mapping:

- macOS: `.app` bundle, native Mach-O launcher, LaunchServices, AppKit host.
- Windows: application manifest, native executable launcher, Win32 host.
- Linux: executable launcher, desktop metadata where applicable, X11/Wayland host.
- iOS: signed application bundle and UIKit lifecycle adapter.
- Android: APK/AAB packaging and Activity lifecycle adapter.
- Browser/WASM: web application assets and browser lifecycle adapter.

An adapter must never hide a failed launch or report success merely because a
platform launcher command accepted the request.
