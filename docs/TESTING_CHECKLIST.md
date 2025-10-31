# Docket Accessibility & Materials Testing Checklist

This checklist helps verify that Docket's design implementation follows Apple's Liquid Glass guidelines across different system configurations.

## Quick Start

```bash
# Build and run Docket
swift run Docket

# Or create .app and install
make app
make install
```

---

## Phase 1: Accessibility Settings Tests

### Test 1: Reduce Transparency

**Purpose**: Verify materials adapt when transparency is disabled

**Steps:**
1. Open **System Settings > Accessibility > Display**
2. Enable **"Reduce transparency"**
3. Launch Docket
4. Observe:
   - [ ] Status bar background becomes more opaque
   - [ ] Window background becomes more opaque
   - [ ] Icons remain visible and legible
   - [ ] No weird artifacts or missing UI elements

**Expected**: App should look more solid/opaque but remain fully functional and legible.

---

### Test 2: Increase Contrast

**Purpose**: Verify color contrast improves for visibility

**Steps:**
1. Open **System Settings > Accessibility > Display**
2. Enable **"Increase contrast"**
3. Launch Docket
4. Observe:
   - [ ] Icon colors become more vibrant/distinct
   - [ ] Text becomes easier to read
   - [ ] Status bar icons have good contrast against background
   - [ ] Meeting rows have clear separation

**Expected**: Higher contrast between foreground and background elements.

---

### Test 3: Reduce Motion

**Purpose**: Verify animations are minimized or removed

**Steps:**
1. Open **System Settings > Accessibility > Display**
2. Enable **"Reduce motion"**
3. Launch Docket
4. Observe refresh icon behavior:
   - [ ] Clock icon still changes to pause icon
   - [ ] No distracting animations during refresh
   - [ ] Pin button rotation is subtle or removed
   - [ ] Eye icon toggle works without excessive animation

**Expected**: State changes visible but without exaggerated motion effects.

---

### Test 4: All Accessibility Settings Combined

**Purpose**: Verify app works with all accessibility features enabled

**Steps:**
1. Enable all three settings:
   - Reduce transparency
   - Increase contrast
   - Reduce motion
2. Launch Docket
3. Observe:
   - [ ] App remains fully functional
   - [ ] All UI elements visible
   - [ ] Icons legible
   - [ ] Status bar readable
   - [ ] Meeting list usable

**Expected**: App should work perfectly with all accessibility features on.

---

## Phase 2: Appearance & Accent Color Tests

### Test 5: Light vs Dark Mode

**Purpose**: Verify materials adapt to system appearance

**Steps:**
1. **Light Mode**:
   - Open **System Settings > Appearance**
   - Select **"Light"**
   - Launch Docket
   - Observe:
     - [ ] Status bar blends with light background
     - [ ] Icons are dark/visible against light chrome
     - [ ] Meeting rows have light appearance
     - [ ] Blue accents visible

2. **Dark Mode**:
   - Select **"Dark"** in System Settings
   - Relaunch Docket
   - Observe:
     - [ ] Status bar blends with dark background
     - [ ] Icons are light/visible against dark chrome
     - [ ] Meeting rows have dark appearance
     - [ ] Blue accents visible

3. **Auto**:
   - Select **"Auto"** in System Settings
   - Test at different times of day
   - Observe:
     - [ ] App transitions smoothly
     - [ ] No broken UI during transition

**Expected**: Seamless appearance in both modes with proper contrast.

---

### Test 6: Accent Colors

**Purpose**: Verify app respects user's chosen accent color

**Steps:**
1. Open **System Settings > Appearance**
2. Change **"Accent color"** dropdown
3. For each color (Blue, Purple, Pink, Red, Orange, Yellow, Green, Graphite):
   - [ ] Pin button uses accent color when pinned
   - [ ] Interactive elements pick up accent appropriately
   - [ ] App feels cohesive with system

**Expected**: Docket should harmonize with chosen system accent color.

---

## Phase 3: Color Profile Tests

### Test 7: Display Profiles

**Purpose**: Verify colors appear correctly on different displays

**Steps:**
1. Open **System Settings > Displays**
2. Click **"Show All Profiles..."**
3. Test with each profile:
   - **Display P3** (wide color):
     - [ ] Colors look vibrant and accurate
     - [ ] Platform colors (Zoom blue, Google Meet green) rich
     - [ ] No weird color shifts

   - **sRGB** (standard):
     - [ ] Colors still look good
     - [ ] No color banding in materials
     - [ ] UI remains legible

**Expected**: App looks good on both wide color and standard displays.

---

## Phase 4: Window Behavior Tests

### Test 8: Window Repositioning

**Purpose**: Verify status bar info is non-critical

**Steps:**
1. Launch Docket
2. Drag window so **bottom edge** is off-screen (below display)
3. Observe:
   - [ ] Can still see meeting list
   - [ ] Can still click meetings
   - [ ] No critical functionality lost
   - [ ] Refresh timestamp hidden (OK - it's non-critical)
   - [ ] Can still access toolbar pin button

**Expected**: App remains usable even when status bar is hidden.

---

### Test 9: Window Resizing

**Purpose**: Verify content adapts fluidly to window size

**Steps:**
1. Launch Docket
2. **Resize smaller**:
   - Drag window edges to make window smaller
   - Observe:
     - [ ] Content reflows appropriately
     - [ ] Status bar scales
     - [ ] No content cut off unexpectedly
     - [ ] Minimum size prevents unusable state

3. **Resize larger**:
   - Drag window edges to make window larger
   - Observe:
     - [ ] Content uses space effectively
     - [ ] Status bar remains at bottom
     - [ ] Meeting list expands properly

**Expected**: Fluid resizing with content adapting to available space.

---

### Test 10: Multiple Displays

**Purpose**: Verify app works across different displays

**If you have multiple displays:**
1. Launch Docket on primary display
2. Drag window to secondary display
3. Observe:
   - [ ] Materials render correctly on both displays
   - [ ] Colors accurate on different display types
   - [ ] Window chrome appears correct
   - [ ] Status bar background consistent

**Expected**: App looks consistent across displays.

---

## Phase 5: Material & Color Validation

### Test 11: Liquid Glass Layer Visual Check

**Purpose**: Verify Liquid Glass is ONLY in functional elements

**Steps:**
1. Launch Docket
2. Visually inspect where frosted glass effect appears:
   - [ ] ✅ Window chrome - YES (Liquid Glass)
   - [ ] ✅ Status bar - YES (Liquid Glass)
   - [ ] ✅ Toolbar area - YES (Liquid Glass)
   - [ ] ❌ Meeting rows - NO (should use standard materials)
   - [ ] ❌ Section headers - NO (should use standard materials)
   - [ ] ❌ Meeting list background - NO (should use standard materials)

**Expected**: Frosted glass effect ONLY on window, toolbar, status bar.

---

### Test 12: Color Sparsity in Liquid Glass

**Purpose**: Verify minimal color usage in functional layer

**Steps:**
1. Launch Docket
2. Inspect status bar icons:
   - Count how many use color vs grayscale
   - Expected ratio: Mostly gray, minimal blue accents
   - [ ] Clock icon: Gray/blue (state-based) ✅
   - [ ] Eye icon: Gray/blue (state-based) ✅
   - [ ] NOT: Rainbow of colors ❌

**Expected**: Monochromatic scheme with blue ONLY for emphasis.

---

### Test 13: Icon Shape + Color Changes

**Purpose**: Verify accessibility through dual feedback

**Steps:**
1. Launch Docket
2. Test each interactive icon:

   **Pin Button:**
   - Unpinned state: [ ] `pin` icon, gray color
   - Pinned state: [ ] `pin.fill` icon, blue color, rotated
   - [ ] Both shape AND color change ✅

   **Eye Button:**
   - Hiding: [ ] `eye.slash` icon, secondary color
   - Showing: [ ] `eye` icon, blue color
   - [ ] Both shape AND color change ✅

   **Clock Button:**
   - Active: [ ] `clock` icon
   - Paused: [ ] `pause.circle.fill` icon
   - [ ] Both shape AND color change ✅

**Expected**: All icons change BOTH shape AND color for accessibility.

---

### Test 14: Tooltip Coverage

**Purpose**: Verify all interactive elements have tooltips

**Steps:**
1. Launch Docket
2. Hover over each button and wait for tooltip:
   - [ ] Pin button - shows tooltip
   - [ ] Eye button (status bar) - shows tooltip
   - [ ] Clock button (status bar) - shows tooltip
   - [ ] Copy button (meeting rows) - shows tooltip
   - [ ] Join button (meeting rows) - shows tooltip

**Expected**: Every interactive icon has a helpful tooltip.

---

## Phase 6: Content Layer Visual Polish

### Test 15: Content vs Functional Layer Distinction

**Purpose**: Verify clear visual hierarchy between layers

**Steps:**
1. Launch Docket with meetings displayed
2. Observe visual hierarchy:
   - [ ] Status bar appears to "float" above content
   - [ ] Toolbar appears to "float" above content
   - [ ] Meeting list feels like it's "under" the chrome
   - [ ] Content shows through translucent materials
   - [ ] Clear separation between functional and content layers

**Expected**: Two distinct layers with Liquid Glass floating above content.

---

### Test 16: Content Layer Color Personality

**Purpose**: Verify brand colors are in content, not Liquid Glass

**Steps:**
1. Launch Docket with Zoom and Google Meet meetings
2. Observe color distribution:
   - **Functional Layer** (status bar, toolbar):
     - [ ] Mostly grayscale ✅
     - [ ] Blue accents for state only ✅
     - [ ] NO platform branding colors ✅

   - **Content Layer** (meeting list):
     - [ ] Zoom meetings show Zoom blue ✅
     - [ ] Google Meet meetings show Google colors ✅
     - [ ] Platform indicators colorful ✅
     - [ ] Meeting status colors visible ✅

**Expected**: Personality and brand colors in content, minimal in functional layer.

---

## Results Summary

After completing all tests, summarize:

### Accessibility
- [ ] All accessibility settings work correctly
- [ ] Light and dark modes both work
- [ ] All accent colors harmonize with app

### Color Profiles
- [ ] P3 and sRGB both render correctly
- [ ] Colors accurate across displays

### Window Behavior
- [ ] Window repositioning doesn't break functionality
- [ ] Resizing works fluidly
- [ ] Multiple displays work correctly

### Materials & Design
- [ ] Liquid Glass ONLY in functional layer
- [ ] Minimal color in Liquid Glass
- [ ] Icons change shape + color
- [ ] All tooltips present
- [ ] Clear two-layer hierarchy

---

## Reporting Issues

If any tests fail, document:
1. Which test failed
2. What you observed vs what was expected
3. System configuration (macOS version, display type, settings)
4. Screenshots if applicable

---

**Testing Date**: _______________
**macOS Version**: _______________
**Tester**: _______________
