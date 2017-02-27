# Arlo Utilities

Command-line utilities that enhance the Arlo Pro experience on Macs.

## Why is this necessary?

The [Arlo Pro](http://www.arlo.com/en-us/products/arlo-pro) allows you to connect up to two USB storage devices for local recording. Unfortunately, there are a number of issues with this:

1. It's not easy to tell when the recording started, because the files have names like `5FO00B3ABC1A1_000000b0_20170223_172955.mp4`, and the time indicated in the filename is in the wrong timezone, so it isn't very helpful anyway
2. The videos don't have a timecode on them, so it's difficult to know exactly when something happened
3. You can't play the recordings in Quicktime. You either need to use VLC, or re-encode them.
4. The Arlo Pro doesn't have CVR (continuous video recording), so you end up with thousands of short video files that are frustrating to quickly review
5. These video files are kept in sequential folders with names like `000001`, which makes it difficult to go directly to a certain day's recordings, because they may be split up in different folders

This script solves all these problems:

1. It accurately figures out when a recording actually started, taking any lag into account
2. It adds a timecode to the video recordings
3. It re-encodes the videos so you can play them in Quicktime
4. It merges the videos together so you can skim an entire day's events
5. It creates one video per day, so you can quickly find the recording you're looking for in your archives

## Installation

You need to install ffmpeg for video encoding to work. Homebrew is the easiest way to do this. I don't know if you actually need *all* of these flags, but it's what the docs suggest, and they worked for me.

```sh
brew install ffmpeg --with-fdk-aac  --with-sdl2 --with-freetype --with-libass --with-libvorbis --with-libvpx --with-opus --with-x265
```

## Tests

To run tests, use make:

```sh
make test
```

A successful test run will produce no output. Any unexpected results will show up as a diff, where `<` indicates expected output, and `>` indicates actual output.

```sh
$ make test
./test.sh | diff ./test-expected.txt -
7c7
< Recording date of file: 02/23/2016
---
> Recording date of file: 02/23/2017
make: *** [test] Error 1
```

## License
Copyright (c) 2017 Ben Ng <me@benng.me>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
