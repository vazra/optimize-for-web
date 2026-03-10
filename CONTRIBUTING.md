# Contributing

Thanks for your interest in contributing to optimize-for-web!

## Getting started

1. Fork the repository
2. Clone your fork
3. Make your changes
4. Test by double-clicking the `.command` file and running it against sample images/videos
5. Submit a pull request

## Guidelines

- Keep it simple — this is a single-file tool, not a framework
- Test on macOS before submitting (this is a Mac-only tool)
- Ensure the script works with filenames that contain spaces and special characters
- Don't add features that require additional dependencies without discussion first

## Reporting bugs

[Open an issue](https://github.com/vazra/optimize-for-web/issues/new?template=bug_report.md) with:
- Your macOS version
- Versions of `node`, `sharp`, and `ffmpeg`
- What you expected vs. what happened
- The Terminal output if available

## Suggesting features

[Open a feature request](https://github.com/vazra/optimize-for-web/issues/new?template=feature_request.md) describing your use case and what you'd like to see.

## Code style

- Bash with `set -uo pipefail`
- Use functions for logical grouping
- Quote all variables
- Handle errors per-file (don't let one failure stop the batch)
