AiVectra

Purpose

AiVectra is a cross-platform application creation system built in AiLang.
It targets macOS, Linux, and Windows.

AiVectra is:

• Deterministic
• Multithreaded (single semantic thread + worker threads)
• Non-blocking
• Solely based on interactive vector primitives
• Designed for AI agents, not humans

This document defines rules that ALL agents must follow when modifying AiVectra or its sample apps.

⸻

	1.	Architectural Model

AiVectra is a UI layer built on top of AiLang and executed by AiVM.

Layer ownership is strict.

AiVM owns:
• Execution engine
• Deterministic state transition
• Worker thread pool (mechanical only)
• Core deterministic event queue
• Thread scheduling mechanics
• Syscall dispatch boundary

AiLang owns:
• Language semantics
• State management
• Control flow
• Data structures
• Concurrency primitives (spawn, message passing, handlers)
• Standard library
• All non-UI APIs

AiVectra owns:
• Vector scene graph
• Rendering
• Focus system
• UI event translation (pointer, keyboard, window events)
• Mapping UI events into the AiLang event system
• UI-related syscalls only

AiVectra does NOT own:
• Concurrency primitives
• Worker scheduling
• Core event queue mechanics
• File IO
• Network IO
• Timers
• Synchronization primitives
• General utilities

If a feature could logically exist without UI, it belongs in AiLang or AiVM.

⸻

	2.	Determinism Is Mandatory

All semantic state mutation must occur on the single UI/Semantic thread.

Workers must never mutate UI state directly.

All cross-thread communication must occur through the AiVM deterministic event queue.

There must be:

• No implicit timers
• No implicit animation loops
• No nondeterministic state mutation
• No version ranges in dependencies

If behavior changes:
	1.	Update SPEC
	2.	Update samples
	3.	Then update implementation

Never the reverse.

⸻

	3.	Threading Model

AiVectra requires:

• One UI/Semantic thread
• Zero or more worker threads

Rules:

• Only the UI thread mutates application state
• Workers perform blocking IO or long-running computation
• Workers communicate completion via message dispatch
• Event queue serializes all state updates
• No shared mutable state across threads

Blocking the UI thread is always incorrect.

⸻

	4.	Event Loop Authority

AiVectra must not create or manage an independent event loop.

All event processing must occur through the AiVM deterministic event queue.

Rendering may be triggered by the host window system, but semantic event processing must remain inside the AiLang/AiVM event system.

AiVectra must not introduce:

• Separate UI message pumps
• Independent scheduling systems
• Animation loops outside the event queue
• Secondary event queues

There must be exactly one semantic event authority: AiVM.

⸻

	5.	Non-Blocking UI

The UI thread must never:

• Sleep
• Wait
• Block on IO
• Perform long-running computation

Long-running work must execute on worker threads and return results via message dispatch.

If a sample blocks the UI thread, it is incorrect.

⸻

	6.	Interactive Vector Only

AiVectra is NOT a widget toolkit.

The engine supports only vector primitives and explicit interaction:

• Group
• Rect
• Ellipse
• Path
• Text
• Transform
• Filters (initially blur only; extensible in future)
• Focus
• Pointer events
• Keyboard events

The engine does NOT support:

• Button
• TextField
• Checkbox
• ScrollView
• Control abstractions
• Widget hierarchies

If an agent attempts to introduce a UI control abstraction into the engine, that change must be rejected.

All UI behavior must be composed from vector primitives and event handlers.

⸻

	7.	Engine Responsibilities

AiVectra provides:

• Scene graph
• Rendering pipeline
• Focus management
• UI event translation
• Integration with AiLang event system

AiVectra does NOT provide:

• High-level widgets
• Implicit layout heuristics
• Hidden lifecycle systems
• Concurrency primitives
• Independent scheduling

⸻

	8.	Sample Applications

The samples directory exists to demonstrate AiVectra capabilities.

Each sample must:

• Demonstrate a specific capability
• Remain minimal
• Be deterministic
• Avoid host-specific hacks
• Avoid engine modifications unless required

Samples should demonstrate:

• Interactive vector composition
• Focus handling
• Keyboard input handling
• Worker thread usage via AiLang concurrency
• Deterministic event dispatch
• Non-blocking behavior
• Rendering correctness
• Filters (blur)
• Gradients
• State-driven rendering

Samples must NOT:

• Introduce control abstractions
• Contain host runtime code
• Depend on platform-specific behavior
• Contain hidden logic

If a sample requires missing engine features:
	1.	Stop
	2.	Report missing capability
	3.	Provide minimal spec for required feature
	4.	Do not implement hacks

⸻

	9.	Debugging and Developer Tools

All debugging capabilities must live in:

• AiVectra engine
or
• aivectra CLI

Never inside sample apps.

Allowed debugging tools include:

• Event tracing
• Worker dispatch tracing
• Frame timing diagnostics
• Determinism verification tools
• Scene graph inspection
• State inspection
• Focus debugging overlay

Agents must use AiLang and AiVectra debugging tools exclusively for runtime diagnosis.

External host tools may be used only to:

• Validate the debugging tools themselves
• Prove a specific debug-tool shortfall

If a required debugging workflow cannot be completed with AiLang/AiVectra tooling:

1. Stop relying on the external tool for normal diagnosis
2. Report the missing debug capability to the owning layer
3. Update the built-in debugging tools
4. Resume diagnosis using those built-in tools

Debug logic must not pollute sample apps.

SDK/CLI debug APIs must be generic and app-agnostic.

Sample apps may call debug APIs, but must not define custom debug output formats.

Do not add sample-specific debug emitters or sample-specific debug schema to `src/AiVectra`.

⸻

	10.	UI-Related Syscalls

AiLang may use UI-related syscalls provided by AiVectra.

Allowed categories:

• Window creation
• Frame presentation
• Input event retrieval
• Focus control
• Render surface management

No UI behavior may be hardcoded in AiVM.

No UI semantics may be defined in host code.

⸻

	11.	Missing Capability Protocol

If during implementation:

• A required feature is missing in AiLang
• A required feature is missing in AiVM
• A required syscall does not exist
• A required concurrency primitive does not exist

The agent must:
	1.	Stop implementation immediately.
	2.	Clearly state:
• What capability is missing
• Why it is required
• Which layer is responsible (AiLang or AiVM)
	3.	Generate a standalone task for that component.

The agent must NOT:

• Implement a workaround inside AiVectra
• Implement the feature in host code
• Duplicate functionality
• Bypass architectural boundaries

If code is a stub, placeholder, or unimplemented path:
• It must fail explicitly at runtime
• It must never silently succeed or silently no-op

If a feature is unavailable on a particular target:
• Emit a compiler/build warning when that can be determined ahead of time
• Raise an explicit runtime not-supported exception if execution still reaches that path

Non-working code must never silently fail.

⸻

	12.	Cross-Platform Constraint

AiVectra must run on:

• macOS
• Linux
• Windows

Host responsibilities:

• Window creation
• Input translation
• Surface presentation

Host must not define UI semantics.

⸻

	13.	Prime Directive

AiVectra must remain:

Deterministic
Non-blocking
Vector-based
Composable
Agent-optimized
Host-independent

If a proposed change violates any of these properties, it must not be implemented.
