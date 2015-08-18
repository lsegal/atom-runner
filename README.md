# Atom Runner

This package will run various script files inside of Atom.
It currently supports JavaScript, CoffeeScript, Ruby, Python, Go, Bash and PowerShell
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
    'coffee': 'coffee'
    'js': 'node'
    'ruby': 'ruby'
    'python': 'python'
    'go': 'go run'
    'shell': 'bash'
    'powershell': 'c:\\windows\\sysnative\\windowspowershell\\v1.0\\powershell.exe -noninteractive -noprofile -c -'
  'extensions':
    'spec.coffee': 'mocha'
    'ps1': 'c:\\windows\\sysnative\\windowspowershell\\v1.0\\powershell.exe –file'
```

**Note**: If a shebang is detected, that line will supersede the
          default registered command.

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

## FAQ And Known Issues

### 1. I keep getting `spawn node ENOENT` errors. Why?

Atom-runner relies on your `PATH` environment variable to run executables through your shell.
In order to correctly run executables, they must be in your `PATH`. In Mac OS X systems,
running Atom.app from the Launchpad or Dock will not source your `PATH` directory additions
from your `~/.bashrc` or other shell profile files, and you are likely not loading your
full set of paths into your environment. 

In order to ensure that your `PATH` is correctly configured in OS X, it is recommended to
load Atom only through an active terminal (i.e., the `atom` command).

## License & Copyright

This package is Copyright (c) Loren Segal 2014 and is licensed under the MIT
license.
