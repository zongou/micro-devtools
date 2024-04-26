# micro plugin devtools

**Provides configurable code formatter and runner based on file type for micro editor.**

## Setup code formatter

```
> set "devtools.formatter.<fileType>" "<formatter>"
```

Examples:

```
> set "devtools.formatter.shell" "shfmt -w"
> set "devtools.formatter.python" "yapf -i"
> set "devtools.formatter.c" "clang-format -i"
> set "devtools.formatter.c++" "clang-format -i"
> set "devtools.formatter.csharp" "clang-format -i"
> set "devtools.formatter.racket" "raco fmt --width 80 --max-blank-lines 2 -i"
> set "devtools.formatter.javascript" "prettier --write --loglevel silent"
> set "devtools.formatter.rust" "rustfmt +nightly"
> set "devtools.formatter.shell" "shfmt -w"
```

## Setup code runner

```
> set "devtools.runner.<fileType>" "<runner>"
```

Examples:

```
> set "devtools.runner.shell" "sh"
> set "devtools.formatter.c" "zig run -lc"
> set "devtools.formatter.c++" "zig run -lc++"
```

## Setup format on save

```
> set "devtools.format-onSave" true
```
