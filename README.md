# MacDraftKit Verified Geometry Refactor

This drop-in refactor separates MD70 parsing into:

- `MD70BinaryReader` — endian-safe binary access
- `MD70Object` models — headers, points, bounds, rectangle and unknown objects
- `MD70ObjectDecoder` — object-type dispatch
- `MD70RectangleDecoder` — confirmed rectangle layout only
- `MD70ObjectSection` — variable-length record traversal
- updated `macdraftinfo` output
- focused geometry and traversal tests

## Install

From the root of your existing MacDraftKit package:

1. Back up or commit your current work.
2. Copy the contents of this archive over the package root.
3. Remove the old `Sources/MacDraftKit/MD70ObjectSection.swift` first if your copy tool does not overwrite it.
4. Run:

```sh
swift test
swift run macdraftinfo /path/to/rectangle.md70
```

## Confirmed rectangle layout

Relative to the object record start:

| Offset | Type | Meaning |
|---:|---|---|
| `0x09` | Float64 BE | top × 10 |
| `0x11` | Float64 BE | left × 10 |
| `0xEF` | Float64 BE | right × 10 |
| `0x107` | Float64 BE | bottom × 10 |

Record traversal uses:

```text
totalLength = storedLength + 12
```

The parser intentionally reports no bounds for circle, ellipse, and other unresolved object layouts.

## API note

`MD70ObjectSection.objects` is now heterogeneous:

```swift
[any MD70DrawingObject]
```

Use type casts for decoded shapes:

```swift
if let rectangle = object as? MD70Rectangle {
    print(rectangle.bounds)
}
```
