# Atom Runner

This package will run various script files inside of Atom.
It currently supports JavaScript, CoffeeScript, Ruby, Python, Go, and Bash
scripts. You can add more!

![Example](https://raw.githubusercontent.com/lsegal/atom-runner/master/resources/screenshot-1.png)

## Using

* Hit Ctrl+R (Alt+R on Win/Linux) to launch the runner for the active window.
* Hit Ctrl+Shift+R (Alt+Shift+R on Win/Linux) to run the currently selected
  text in the active window.
* Hit Ctrl+Shift+C to kill a currently running process.
* Hit Escape to close the runner window.

## Features

* A docked runner window with ANSI support and ESC keybinding to close.
* PATH and environment variable detection on OSX.
* Shebang executable detection in all source files.
* Configurable commands based on file scope or filename matches.
* Execute unsaved file buffers!

## Configuring

This package uses the following default configuration:

```cson
'runner':
  'scopes':
    'coffee': 'coffee {file_path}'
    'js': 'node {file_path}'
    'ruby': 'ruby {file_path}'
    'python': 'python {file_path}'
    'go': 'go run {file_path}'
    'shell': 'bash {file_path}'
  'extensions':
    'spec.coffee': 'mocha'
```

**Note**: If a shebang is detected, that line will supersede the
          default registered command.

The variable `{file_path}` is used to replace the current file path in the
command. If it is not given (e.g. `'js': 'npm test'`) it will not be embedded
such path on the command, so the custom command will be run.

You can add more commands for a given language scope, or add commands by
extension instead (if multiple extensions use the same syntax). Extensions
are searched before scopes (syntaxes).

To do so, add the configuration to `~/.atom/config.cson` in the format provided
above.

The mapping is `SCOPE|EXT => EXECUTABLE`, so to run JavaScript files through
phantom, you would do:

```cson
'runner':
  'scopes':
    'js': 'phantom'
```

Note that the `source.` prefix is ignored for syntax scope listings.

Similarly, in the extension map:

```cson
'runner':
  'extensions':
    'js': 'phantom'
```

Note that the `.` extension prefix is ignored for extension listings.

## License & Copyright

This package is Copyright (c) Loren Segal 2014 and is licensed under the MIT
license.
