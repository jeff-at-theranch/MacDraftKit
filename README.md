# MacDraftKit

MacDraftKit is an open-source Swift library and command-line toolkit for reading MacDraft `.md70` documents. Its first goal is dependable discovery and extraction of the PDF payload embedded in many MD70 files, enabling previews, inspection, and document preservation on modern macOS.

## Build

```bash
swift build
swift test
```

## Command-line tools

Inspect a document:

```bash
swift run macdraftinfo Drawing.md70
```

Extract its embedded PDF:

```bash
swift run macdraftextract Drawing.md70 Drawing.pdf
```

## Project status

MacDraftKit is early-stage software based on observed files rather than a published MacDraft specification. Format discoveries are documented and tested as the project develops.

## License

MIT License. See `LICENSE`.
