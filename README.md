# micro plugin devtools

Provides configurable code formatter and runner based on file type for micro editor.

Options:

| Option                        | Value      | Default |
| ----------------------------- | ---------- | ------- |
| devtools.formatOnSave         | true/false | false   |
| devtools.formatter.[filetype] | string     |         |
| devtools.runner.[filetype]    | string     |         |

Commands:

| Command | Detail          |
| ------- | --------------- |
| f       | format          |
| x       | run             |
| xi      | run interactive |

Key
| Key Binding Values |
| ----------------------------- |
| lua:devtools.doFormat |
| lua:devtools.doRun |
| lua:devtools.doRunInteractive |

## Examples

Formatter

```micro
> set devtools.formatter.shell "shfmt -w"
> set devtools.formatter.c "clang-format -i"
> set devtools.formatter.c++ "clang-format -i"
> set devtools.formatter.csharp "clang-format -i"
> set devtools.formatter.python "yapf -i"
> set devtools.formatter.racket "raco fmt --width 80 --max-blank-lines 2 -i"
> set devtools.formatter.javascript "prettier --write --loglevel silent"
> set devtools.formatter.rust "rustfmt +nightly"
```

Runner

```micro
> set devtools.runner.shell "sh"
> set devtools.formatter.c "zig run -lc"
> set devtools.formatter.c++ "zig run -lc++"
```
