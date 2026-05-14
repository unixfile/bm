# bm

[![CI](https://github.com/unixfile/bm/actions/workflows/ci.yml/badge.svg)](https://github.com/unixfile/bm/actions/workflows/ci.yml)

Set, list and delete directory bookmarks. Jump by name via CDPATH.

## Install

```sh
git clone https://github.com/unixfile/bm
cd bm
make install
```

For the man page (requires pandoc):

```sh
make man
man ./bm.1
```

## Usage

```
bm                        List all bookmarks
bm <name> [path]          Set bookmark <name> for path (default: current directory)
bm -d, --delete <name>    Delete bookmark <name>
bm -h, --help             Show this help
. bm                      Source into shell to enable: cd <bookmark>
```

Source first, then set and jump:

```sh
bm work ~/projects/myapp   # set bookmark "work"
cd work                    # jumps there via CDPATH
```

## Shell integration

Source in your shell's rc file:

```sh
. bm
```

Prepends `${XDG_CONFIG_HOME:-~/.config}/cdpath/` to `CDPATH` in any POSIX shell. Tab-completion for bookmark names is available in bash and zsh.

## Options

| Option | Description |
|--------|-------------|
| `-d`, `--delete <name>` | Delete bookmark |
| `-h`, `--help` | Show help and exit |

## License

MIT. See [LICENSE](LICENSE).
