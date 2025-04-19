# fuse-archive.yazi

[fuse-archive.yazi](https://github.com/dawsers/fuse-archive.yazi)
uses [fuse-archive](https://github.com/google/fuse-archive) to
transparently mount and unmount archives in read-only mode, allowing you to
navigate inside, view, and extract individual or groups of files.

There is another plugin on which this one is based,
[archivemount.yazi](https://github.com/AnirudhG07/archivemount.yazi). It
mounts archives with read and and write permissions. The main problem is it uses
[archivemount](https://github.com/cybernoid/archivemount) which is much slower
than [fuse-archive](https://github.com/google/fuse-archive).
It also supports very few file types compared to this plugin, and you need to
mount and unmount the archives manually.

[fuse-archive.yazi](https://github.com/dawsers/fuse-archive.yazi) supports
mounting the following file extensions: `.zip`, `.gz`, `.bz2`, `.tar`, `.tgz`,
`.tbz2`, `.txz`, `.xz`, `.tzs`, `.zst`, `.iso`, `.rar`, `.7z`, `.cpio`, `.lz`,
`.lzma`, `.shar`, `.a`, `.ar`, `.apk`, `.jar`, `.xpi`, `.cab`.

## Requirements

1. A relatively modern (>= 0.3) version of
[yazi](https://github.com/sxyazi/yazi).

2. This plugin only supports Linux, and requires having
[fuse-archive](https://github.com/google/fuse-archive) installed. It should be
available in most Linux distributions.

## Installation

```sh
ya pack -a dawsers/fuse-archive
```

Modify your `~/.config/yazi/init.lua` to include:

``` lua
require("fuse-archive"):setup()
```

### Options

The plugin supports the following options, which can be assigned during setup:

1. `smart_enter`: If `true`, when *entering* a file it will be *opened*, while
directories will always be *entered*. The default value is `false`.

2. `mount_dir`: An absolute path. If set, archives will be mounted to that
directory instead of the default one. If not set, the default directory is
chosen by testing, in this order: `$XDG_STATE_HOME`, `$HOME/.local/state`
and `/tmp`. `fuse-archive.yazi` will append `yazi/fuse-archive` to the chosen
directory.

``` lua
require("fuse-archive"):setup({
  smart_enter = true,
  mount_dir = "/tmp",
})
```

### Possible Conflicts

You may run into trouble with certain archives if `yazi.toml` has an opener
that extracts archives (the default opener defined as preset does that):

``` toml
extract = [
	{ run = 'ya pub extract --list "$@"', desc = "Extract here", for = "unix" },
	{ run = 'ya pub extract --list %*',   desc = "Extract here", for = "windows" },
]
```

The plugin still works, but the UI may be confusing.
In that case, modify your `yazi.toml` to contain:

``` toml
extract = [
]
```

and now *fuse-archive* will be the one mounting and showing the contents of the
archive.

## Usage

The plugin works transparently, so for the best effect, remap your navigation
keys assigned to `enter` and `leave` to the plugin. This way you will be able
to "navigate" compressed archives as if they were part of the file system.

When you *enter* an archive, the plugin mounts it and takes you to the mounted
directory, and when you *leave*, it unmounts the archive and takes you back to
the original location of the archive.

Add this to your `~/.config/yazi/keymap.toml`:

``` toml
[manager]
prepend_keymap = [
    { on   = [ "<Right>" ], run = "plugin fuse-archive --args=mount", desc = "Enter or Mount selected archive" },
    { on   = [ "<Left>" ], run = "plugin fuse-archive --args=unmount", desc = "Leave or Unmount selected archive" },
]
```

When the current file is not a supported archive type, the plugin simply calls
*enter*, and when there is nothing to unmount, it calls *leave*, so it works
transparently.

In case you run into any problems and need to unmount something manually, or
delete any temporary directories, the location of the mounts is one of the
following three in order of preference:

1. `$XDG_STATE_HOME/yazi/fuse-archive/...`
2. `$HOME/.local/state/yazi/fuse-archive/...`
3. `/tmp/yazi/fuse-archive/...`

or the directory you set in `mount_dir`, if any.
