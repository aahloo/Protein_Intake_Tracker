# SummaryView Runtime Fix

## Issue Identified
The SummaryView was crashing due to two main problems:

### 1. ForEach ID Problem
**Original problematic code:**
```swift
ForEach(last7Days(), id: \.self) { date in
```

**Problem:** Using `Date` as `id: \.self` is unreliable because Date objects may not be unique enough for SwiftUI's identification requirements.

**Fix:**
```swift
ForEach(Array(last7Days().enumerated()), id: \.offset) { index, date in
```

### 2. Invalid Range
**Original problematic code:**
```swift
for i in 6..<0 {  // This range is invalid!
```

**Problem:** The range `6..<0` is invalid and would cause runtime issues.

**Fix:**
```swift
for i in (1...6).reversed() {
```

## Changes Made

1. **Fixed ForEach identification** - Use enumerated array with offset as ID
2. **Fixed date range calculation** - Use proper reversed range for last 6 days
3. **Maintained functionality** - The chart still shows the last 7 days of data

## Test Status
- ✅ Build succeeds
- ✅ No compilation errors 
- ✅ Runtime crash should be resolved

## Testing Recommendations
1. Navigate to Summary tab
2. Verify the weekly chart displays without crashing
3. Add some nutrition entries and verify the chart updates
4. Test with empty data to ensure graceful handling

The SummaryView should now load properly without runtime crashes.