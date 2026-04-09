# shred — secure file overwrite utility

A lightweight, cross-compatible secure file overwrite utility written in shell.

Originally, `shred` is not natively available on macOS systems. This project was created to provide similar functionality for macOS users, while remaining fully compatible across Linux and other Unix-like environments.

## Usage

```bash
shred [-v] [-n N] [-z] [-k] FILE|DIR
```

## Options

- `-v` Verbose output
- `-n N` Number of random overwrite passes (default: 3)
- `-z` Perform a final overwrite with zeros
- `-k` Keep files after overwriting
- `-h` Show help message

## Examples

```bash
shred -n 3 -z /path/to/file
shred -v /path/to/dir
shred -n 1 -k ./somefile.txt
```

## Notes

- Overwrites files in-place and (when supported) restores original file size.
- Skips non-regular files.
- Not guaranteed to erase data on SSDs, copy-on-write filesystems, snapshots, backups, or remote storage.
- Requires write permission; use `sudo` if necessary.

## Install

Run the provided `installer.sh` to install system-wide or per-user:

```bash
chmod +x ./installer.sh
```

```bash
./installer.sh
./installer.sh --system
./installer.sh --user
```

## Uninstall

```bash
# system (if installed system-wide)
sudo rm /usr/local/bin/shred

# user (if installed to ~/.local/bin)
rm "$HOME/.local/bin/shred"
```

## License

MIT License

Copyright (c) 2026 Michael Rogers

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
