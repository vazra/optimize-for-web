<p align="center">
  <img src="icon.png" width="128" height="128" alt="Optimize for Web icon">
</p>

# optimize-for-web

A zero-dependency Mac app that optimizes images and videos for the web. No Homebrew, no Node.js, no setup — just download, open, and optimize.

Select your files, pick an output folder, and get web-ready assets in seconds.

## What it does

| Input | Output | Settings |
|-------|--------|----------|
| JPG, JPEG, PNG | WebP | Quality 90, max 1920px wide, metadata stripped |
| MP4, MOV | MP4 + WebM | H.264 (CRF 28) + VP9 (CRF 42), no audio, metadata stripped |

- Originals are never modified
- Optimized files go to a folder you choose
- Shows a completion dialog with results

### Typical savings

| File type | Before | After | Reduction |
|-----------|--------|-------|-----------|
| 6.5MB PNG photo | 6.5MB | ~200KB | 97% |
| 2.7MB JPG thumbnail | 2.7MB | ~350KB | 87% |
| 30MB raw MP4 video | 30MB | ~3MB MP4 + ~1.5MB WebM | 90% |

## Installation

### Download the app

1. Download `optimize-for-web-macos-arm64.zip` from the [latest release](https://github.com/vazra/optimize-for-web/releases/latest)
2. Unzip it
3. Drag `optimize-for-web.app` to your Applications folder (or anywhere you like)

**No Homebrew, no Terminal commands, no dependencies.** Everything is bundled inside the app.

> **Note:** This is currently built for Apple Silicon (M1/M2/M3/M4) Macs only.

## Usage

1. Double-click `optimize-for-web.app`
2. Select images or videos to optimize
3. Choose an output folder
4. A dialog shows the results when done

### Keep in Dock

Drag the app to your Dock for quick access.

## macOS Gatekeeper

On first launch, macOS will block the app with *"Apple could not verify..."*. To fix this:

1. Double-click the app — macOS will block it — click **Done**
2. Open **System Settings → Privacy & Security**
3. Scroll down — you'll see a message about the app being blocked
4. Click **Open Anyway**
5. Enter your password when prompted

This only needs to be done once. After that, the app opens normally.

## How it works

The app bundles static binaries of:
- [**cwebp**](https://developers.google.com/speed/webp/) (Google's WebP encoder) for image conversion
- [**ffmpeg**](https://ffmpeg.org/) for video conversion

No external tools or runtimes are needed on the user's machine.

## Video encoding details

**MP4 (H.264):**
- CRF 28, baseline profile, level 3.0
- `faststart` flag for streaming
- No audio track
- All metadata stripped

**WebM (VP9):**
- CRF 42, bitrate 0 (quality-constrained)
- `deadline good`, `cpu-used 3`
- No audio track
- All metadata stripped

## Advanced: command-line usage

The app also ships as a standalone `.command` file for Terminal users who prefer the CLI. See the [releases page](https://github.com/vazra/optimize-for-web/releases) for both formats.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE)
