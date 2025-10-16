# Docket Design System

This document explains the design decisions in Docket based on Apple's Human Interface Guidelines for Windows, Materials, and Color.

## Architecture Overview

Docket follows Apple's recommended **two-layer material system**:

```
┌─────────────────────────────────────────┐
│ LIQUID GLASS LAYER (Functional)        │
│  • Window chrome                        │
│  • Toolbar (PinButton)                  │
│  • Status Bar (clock + eye icons)      │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ CONTENT LAYER (Standard Materials)│ │
│  │  • Meeting list (List component)  │ │
│  │  • Section headers                │ │
│  │  • Meeting rows                   │ │
│  │  • Platform indicators            │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Materials

### Liquid Glass (Functional Layer)

Per Apple's guidelines: *"Liquid Glass forms a distinct functional layer for controls and navigation elements that floats above the content layer"*

**Used in Docket:**
- **Window**: `.containerBackground(.ultraThinMaterial, for: .window)` (DocketApp.swift:26)
- **Status Bar**: `.background(.ultraThinMaterial)` (StatusBar.swift:38)

**Why**: These are functional navigation elements that should float above content and allow content to peek through.

### Standard Materials (Content Layer)

Per Apple's guidelines: *"Don't use Liquid Glass in the content layer... use standard materials for elements in the content layer"*

**Used in Docket:**
- **Meeting List**: SwiftUI `List {}` component (uses system default materials)
- **Meeting Rows**: Standard SwiftUI backgrounds
- **Section Headers**: System-provided styling

**Why**: Content should use standard materials to create visual distinction within the content layer, not compete with the functional layer.

## Color Philosophy

### Minimal Color in Liquid Glass

Per Apple's guidelines: *"Use color sparingly in Liquid Glass. Reserve it for elements that truly benefit from emphasis, such as status indicators or key actions"*

**Implementation:**
- **Status bar icons**: Mostly monochromatic (gray/secondary)
- **Blue accent**: ONLY for state emphasis
  - Eye icon: Blue when showing all meetings (non-default state)
  - Pin icon: Blue when pinned (active state)
  - Clock icon: Blue during active refresh states
- **No brand colors**: Liquid Glass stays minimal

### Brand Colors in Content Layer

Per Apple's guidelines: *"Consider using color in the content layer to evoke your brand"*

**Implementation:**
- **Platform indicators**: Zoom blue, Google Meet colors
- **Meeting status**: Color-coded states (green=active, blue=upcoming)
- **Content badges**: Colored completion badges

**Why**: Brand personality lives in the content, not in navigation chrome.

### Semantic Color Usage

Per Apple's guidelines: *"Each dynamic color is semantically defined by its purpose, rather than its appearance"*

**Color Meanings in Docket:**
- `Color.secondary`: Default/inactive state (icons, subtitles)
- `Color.primary`: Primary content (titles, active icons)
- `Color.blue`: Interactive/selected state (pinned, non-default settings, active refresh)
- Platform colors: Platform identity (Zoom blue, Google Meet green)

**Never used**: Hard-coded colors like `Color(white: 0.5)` or `.foregroundColor(.systemGray3)`

## Vibrancy

Per Apple's guidelines: *"Help ensure legibility by using vibrant colors on top of materials"*

**Implementation:**
- ALL icons use `.foregroundStyle()` with semantic Color types
- NEVER use `.foregroundColor()` (disables vibrancy)
- Example: `StatusBarHideCompletedItem.swift:15`

```swift
.foregroundStyle(isHiding ? Color.secondary : Color.blue)
```

**Why**: `.foregroundStyle()` with hierarchical Color types enables automatic vibrancy with materials.

## Accessibility

### Icons Change Shape + Color

Per Apple's guidelines: *"Avoid relying solely on color to differentiate"*

**Implementation:** Every interactive icon changes BOTH shape AND color:

| Icon | Default | Active | Accessibility |
|------|---------|--------|---------------|
| Pin | `pin` (gray) | `pin.fill` + rotation (blue) | ✅ Shape + color |
| Eye | `eye` (blue) | `eye.slash` (gray) | ✅ Shape + color |
| Clock | `clock` | `pause.circle.fill` | ✅ Shape + color |
| Join | `video` | `video.fill` | ✅ Shape + color |

**Why**: People with color blindness can distinguish states by shape alone.

### Tooltips on All Icons

Per Apple's guidelines: *"Provide the same information in alternative ways"*

**Implementation:**
- ✅ All icon buttons have `.help()` tooltips
- ✅ Tooltips explain state-specific actions
- ✅ Example: "Show all completed meetings (currently hiding meetings 5 minutes after completion)"

**Why**: Screen readers and Voice Control users need text descriptions.

## Window Design

### System-Provided Windows

Per Apple's guidelines: *"Avoid creating custom window UI... Avoid making custom window frames or controls"*

**Implementation:**
- `.windowStyle(.automatic)` - Uses system window frame
- `.windowResizability(.contentSize)` - System-provided resize behavior
- Default window controls (close, minimize, zoom)

**Why**: System windows adapt to macOS appearance changes automatically.

### Bottom Bar (Status Bar)

Per Apple's guidelines: *"Avoid putting critical information or actions in a bottom bar, because people often relocate a window in a way that hides its bottom edge"*

**Implementation:**
- Status bar shows: Refresh timestamp (info) + Hide toggle (preference)
- Neither is critical for app operation
- Main actions (join meeting) are in content area

**Why**: Non-critical supplementary information is safe in bottom bar.

## Testing Requirements

Per Apple's guidelines, test with:

1. **Accessibility Settings**
   - [ ] Reduce Transparency enabled
   - [ ] Increase Contrast enabled
   - [ ] Reduce Motion enabled

2. **Appearance Modes**
   - [ ] Light mode
   - [ ] Dark mode
   - [ ] All macOS accent colors (System Settings > Accent color)

3. **Color Profiles**
   - [ ] Display P3 (wide color)
   - [ ] sRGB (standard)

4. **Window Behavior**
   - [ ] Window repositioning (bottom edge off-screen)
   - [ ] Window resizing (minimum/maximum)
   - [ ] Multiple displays

## Key Decisions

### ✅ What We're Doing Right

1. **Two-layer architecture**: Liquid Glass for functional, standard materials for content
2. **Minimal Liquid Glass usage**: Only window, toolbar, status bar
3. **Monochromatic functional layer**: Status bar and toolbar are mostly grayscale
4. **Semantic colors**: `.secondary`, `.primary`, `.blue` instead of hard-coded values
5. **Vibrancy-enabled**: Using `.foregroundStyle()` throughout
6. **Accessible icons**: All change shape + color
7. **Complete tooltips**: All interactive elements have `.help()`

### 🎯 Future Opportunities

1. **Colorful section headers**: Could add subtle color to "Today/Yesterday/Tomorrow" in content layer
2. **Meeting status borders**: Left-edge color coding (green=active, blue=upcoming)
3. **Enhanced platform badges**: Subtle background tints in content layer

### ❌ What We Avoid

1. **Liquid Glass in content**: Never use materials in meeting list items
2. **Color for decoration**: Blue only for semantic meaning (interactive/selected)
3. **Custom window chrome**: Always use system-provided windows
4. **Hard-coded colors**: Never use `Color(white: 0.5)` or non-semantic values
5. **Color-only states**: Always change icon shape when changing color

## References

- [Apple HIG: Windows](https://developer.apple.com/design/human-interface-guidelines/windows)
- [Apple HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- [Apple HIG: Color](https://developer.apple.com/design/human-interface-guidelines/color)
- [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)

---

**Last Updated**: 2025-10-14
**macOS Target**: 15.0+
**Swift Version**: 6.0
