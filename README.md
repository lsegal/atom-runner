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

You can add more commands for a given language scope, or add commands by
extension instead (if multiple extensions use the same syntax). Extensions
are searched before scopes (syntaxes).

To do so, add the configuration to `~/.atom/config.cson` in the format provided
below, which also represents the default configuration for this plugin:

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

**IMPORTANT NOTE**: Spaces are significant in the configuring of `.cson`
files. You *must* follow the exact indentation provided in the example
above using spaces (no tabs).

If a [shebang][sh] is detected in the source code, that line will supersede the
default registered command.

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
full set of paths into your environment. In Windows systems, you configure your `PATH`
environment through the [Advanced System Settings panel][winconfig].

In order to ensure that your `PATH` is correctly configured in OS X, it is recommended to
load Atom only through an active terminal (i.e., the `atom` command).

### 2. I am hitting Alt+R (or Cmd+R) and nothing is happening.

It is possible that the language you are writing code in is not recognized by this plugin
in its default configuration. See the configuring section above to add support for your
language or file extension if it is not there.

### 3. This plugin is broken! Should I file a bug report?!

Before you open a bug report, please make sure that you have properly configured the
plugin for your environment. There are a lot of external factors that can cause the
plugin to fail that are dependent on the language you are using, the code you are
writing, the OS you are on, and much more. Please be mindful that this plugin is
developed for many different languages and third-party tools, and the details of
a single environment may not be immediately obvious.

Opening a bug report that says the plugin is "not working" is not helpful and will
likely end up being closed due to lack of reproduceability. Unfortunately it is not
possible to provide detailed configuration instructions for each language and/or
environment combination in the bug tracker.

If you believe you have found a legitimate bug and can provide reliable reproduction
steps to show the issue, please file a bug report. Please make sure that you provide
detailed steps and include your environment (OS), language, and, if relevant, any
source code you executed when running into the issue. Without this information,
it is not always possible to know what is broken, and this will slow down the
ability to provide a quick patch for any bugs. 

Thanks for cooperating!

## License & Copyright

This package is Copyright (c) Loren Segal 2014 and is licensed under the MIT
license.

[sh]: https://en.wikipedia.org/wiki/Shebang_(Unix)
[winconfig]: http://www.computerhope.com/issues/ch000549.htm
