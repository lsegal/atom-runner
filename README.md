# Atom Runner

This package will run various script files inside of Atom.
It currently supports JavaScript, CoffeeScript, Ruby, Python, and Go. You
can add more.

![Example](http://github.com/lsegal/atom-runner/raw/master/resources/screenshot-1.png)

## Using

* Hit Cmd+R to launch the runner for the active window.
* Hit Ctrl+C to kill a currently running process.

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
  'extensions':
    'spec.coffee': 'jasmine-node --coffee'
```

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
