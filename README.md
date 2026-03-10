# optimize-for-web

A double-click Mac tool that optimizes images and videos for the web. No GUI framework, no Electron — just native macOS dialogs and a Terminal window showing progress.

Select your files, pick an output folder, and get web-ready assets in seconds.

## What it does

| Input | Output | Settings |
|-------|--------|----------|
| JPG, JPEG, PNG | WebP | Quality 90, max 1920px wide, metadata stripped |
| MP4, MOV | MP4 + WebM | H.264 (CRF 28) + VP9 (CRF 42), no audio, metadata stripped |

- Originals are never modified
- Optimized files go to a folder you choose
- Shows file sizes before and after

### Typical savings

| File type | Before | After | Reduction |
|-----------|--------|-------|-----------|
| 6.5MB PNG photo | 6.5MB | 176KB | 97% |
| 2.7MB JPG thumbnail | 2.7MB | 357KB | 87% |
| 30MB raw MP4 video | 30MB | ~3MB MP4 + ~1.5MB WebM | 90% |

## Prerequisites

Install these once via [Homebrew](https://brew.sh):

```bash
brew install node ffmpeg
npm install -g sharp
```

> **Note:** `ffmpeg` is only needed if you optimize videos. Image-only usage requires just `node` and `sharp`.

## Installation

### Option 1: Download

Download `optimize-for-web.command` from the [latest release](https://github.com/vazra/optimize-for-web/releases/latest).

### Option 2: Clone

```bash
git clone https://github.com/vazra/optimize-for-web.git
```

Make it executable:

```bash
chmod +x optimize-for-web.command
```

## Usage

### Double-click

1. Double-click `optimize-for-web.command` in Finder
2. Select images or videos to optimize
3. Choose an output folder
4. Wait for the Terminal to show results
5. A notification plays when done

### From Terminal

```bash
./optimize-for-web.command
```

### Keep in Dock

Drag `optimize-for-web.command` to your Dock for quick access.

## macOS Gatekeeper

On first launch, macOS will block the script with *"Apple could not verify..."*. To fix this:

1. Make it executable (once): open Terminal and run `chmod +x ~/Downloads/optimize-for-web.command`
2. Open **System Settings → Privacy & Security**
3. Double-click the file — macOS will block it with *"Apple could not verify..."* — click **Done**
4. Open **System Settings → Privacy & Security**, scroll down
5. Click **Open Anyway** next to the blocked message
6. Enter your password when prompted

This only needs to be done once. After that, the tool opens normally.

> **Tip:** On older macOS versions (pre-Sequoia), you can right-click the file and select **Open** instead.

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

## License

[MIT](LICENSE)
