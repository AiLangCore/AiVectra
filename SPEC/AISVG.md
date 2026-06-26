# SPEC/AISVG.md

Status: Draft

## Purpose

AiSVG is AiVectra's declarative vector UI markup language.

AiSVG provides SVG-inspired UI composition using AiLang's token-oriented syntax.

AiSVG is:

- Human readable
- AI-friendly
- Deterministic
- Canonically formattable
- Cross-platform

AiSVG is not:

- XML
- JSON
- Browser SVG
- XAML
- HTML

AiSVG is a view language for AiVectra.

---

# Architecture

AiSVG follows a deterministic Model → Update → View architecture.

```text
Model
  ↓
View (.aisvg)
  ↓
Event
  ↓
Update
  ↓
Model
```

The architecture is intentionally simple, deterministic, and AI-friendly.

---

# File Structure

Views are composed of two files:

```text
Views/
  MainView.aisvg
  MainView.aisvg.aos
```

The `.aisvg` file owns:

- visual structure
- layout
- vector graphics
- bindings
- event declarations
- animation declarations

The `.aisvg.aos` file owns:

- models
- events
- update handlers
- commands
- business logic

Many IDEs automatically group files using this naming convention.

---

# Semantic Authority

AiSVG defines visual intent.

AiLang defines meaning.

AiVM executes meaning.

Native hosts render the resulting scene.

Renderer implementations must not alter AiSVG semantics.

---

# Basic Structure

```ailang
Svg MainView
{
    ViewBox 0 0 800 600

    Rect background
    {
        X 0
        Y 0
        Width 800
        Height 600
        Fill "#1e293b"
    }

    Text title
    {
        X 40
        Y 80

        FontSize 32
        Fill "#ffffff"

        Value model.title
    }
}
```

---

# Core Elements

Required v1 elements:

```text
Svg
Group

Rect
Circle
Ellipse
Line
Path
Text
Image

Defs
Use
ClipPath

LinearGradient
RadialGradient

Animate
AnimateTransform
Set
```

Future elements:

```text
Symbol
Pattern
Mask
Filter
Blur
DropShadow
```

---

# Clipping

AiSVG supports deterministic path-based clipping through `ClipPath`.

`ClipPath` defines a reusable clipping path. Rendering code may apply a clip
path to subsequent draw operations through a scoped push/pop operation. The
active clip stack affects visual output only:

- clipping does not change layout
- clipping does not remove scene elements
- clipping does not change hit-test semantics unless a higher-level component
  explicitly defines clipped hit testing
- renderers may accelerate clipping mechanically, but AiVectra owns the clip
  path and stack semantics

Rectangular viewport clipping should be represented as a closed path:

```text
M x y L x2 y L x2 y2 L x y2 Z
```

Non-closed paths are valid. Renderers fill the path according to the renderer's
normal path fill behavior before applying it as a clip region.

---

# Paint System

AiSVG separates geometry from paint definitions.

## Paint Types

Supported paint types:

```text
SolidColor
LinearGradient
RadialGradient
```

Future paint types:

```text
Pattern
ImageBrush
Noise
```

---

# Gradients

## Linear Gradient

```ailang
Defs
{
    LinearGradient sky
    {
        Stop 0% "#0f172a"
        Stop 100% "#1d4ed8"
    }
}
```

Usage:

```ailang
Rect background
{
    Width 800
    Height 600

    Fill sky
}
```

## Radial Gradient

```ailang
Defs
{
    RadialGradient spotlight
    {
        Stop 0% "#ffffff"
        Stop 100% "#000000"
    }
}
```

Usage:

```ailang
Circle glow
{
    Radius 100

    Fill spotlight
}
```

## Gradient Stops

A gradient consists of one or more color stops.

Preferred syntax:

```ailang
LinearGradient sunset
{
    Stop 0% "#ff0000"
    Stop 50% "#ffcc00"
    Stop 100% "#0000ff"
}
```

Expanded syntax is valid:

```ailang
LinearGradient sky
{
    Stop
    {
        Offset 0%
        Color "#0f172a"
    }

    Stop
    {
        Offset 100%
        Color "#1d4ed8"
    }
}
```

Formatters should prefer shorthand syntax.

---

# Properties

Properties use token-oriented syntax.

```ailang
Rect card
{
    X 20
    Y 20

    Width 320
    Height 160

    Fill "#ffffff"

    Stroke "#000000"
    StrokeWidth 2
}
```

---

# Expressions

Any property may contain an AiLang expression.

Literal:

```ailang
Value "Weather"
```

Binding:

```ailang
Value model.title
```

Computed:

```ailang
Value model.temperature ++ "°F"
```

Conditional:

```ailang
Visible model.isLoaded
```

Bindings are expressions.

Bindings are not strings.

Invalid:

```ailang
Value "`model.title`"
```

---

# Models

Models are defined in the companion `.aisvg.aos` file.

```ailang
Model MainViewModel
{
    title = "Weather"
    temperature = 72
}
```

---

# Events

Events are defined in AiLang.

```ailang
Event RefreshClicked
{
}
```

Usage:

```ailang
Group refreshButton
{
    OnClick RefreshClicked
}
```

---

# Updates

All state mutation occurs through Update handlers.

```ailang
Update RefreshClicked
{
    loading = true
}
```

Views never mutate state directly.

---

# Components

AiSVG supports reusable components.

Directory structure:

```text
Views/
  Components/
    WeatherCard.aisvg
    WeatherCard.aisvg.aos
```

Component definition:

```ailang
Component WeatherCard
{
    Props
    {
        title Text
        temperature Text
    }

    Events
    {
        RefreshClicked
    }

    Svg
    {
        Text titleText
        {
            Value title
        }

        Text tempText
        {
            Value temperature
        }
    }
}
```

Usage:

```ailang
Use Components.WeatherCard

Svg MainView
{
    WeatherCard current
    {
        Title model.city
        Temperature model.temperature

        On RefreshClicked RefreshWeather
    }
}
```

---

# Component Rules

Components receive data through Props.

Components communicate outward through Events.

Components should avoid hidden mutable state.

All component behavior must remain deterministic.

---

# AI Metadata

AiSVG supports optional non-rendering metadata.

```ailang
Text title
{
    Role heading

    Intent "Displays the page title."

    TestId titleText

    Value model.title
}
```

Supported metadata:

```text
Role
Intent
TestId
Notes
StateSource
Action
```

Metadata must not affect rendering.

---

# Animation

AiSVG supports deterministic declarative animation.

```ailang
Animate fadeIn
{
    Target title.Opacity

    From 0
    To 1

    Duration 250ms

    Easing linear
}
```

Transform animation:

```ailang
AnimateTransform drift
{
    Target cloud.Transform

    Type translate

    From "0 0"
    To "20 0"

    Duration 1000ms

    Repeat forever

    Direction alternate
}
```

---

# Animation Rules

Animation state must be deterministic.

Animation is derived from:

- model state
- event history
- viewport
- target profile
- deterministic timeline

Animation semantics must not depend on host wall-clock behavior.

---

# SVG Compatibility

AiSVG intentionally mirrors common SVG concepts:

```text
Svg
Group
Rect
Circle
Ellipse
Path
Text
Image
Defs
Use
Transform
Animate
```

AiSVG is not required to support full browser SVG behavior.

Browser-specific behavior is out of scope.

---

# Rendering

AiSVG lowers into canonical AiVectra scene records.

Renderers consume scene records.

Renderer selection must not alter AiSVG semantics.

---

# Validation

Validation must reject:

- duplicate IDs
- unknown properties
- invalid bindings
- unresolved events
- unresolved component references
- invalid animation targets
- unsupported SVG features

Validation must be deterministic.

---

# Determinism

For a given:

- AiSVG
- model state
- event stream
- viewport
- target profile

AiVectra must produce identical scene output.

If behavior changes:

1. Update spec.
2. Update goldens.
3. Update implementation.

Never the reverse.

---

# Prime Rule

AiSVG describes visual intent.

AiLang owns meaning.

AiVM executes meaning.

Native hosts render the result.
