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
    'coffee':
      'cmd': 'coffee'
    'js':
      'cmd': 'node'
    'ruby':
      'cmd': 'ruby'
    'python':
      'cmd': 'python'
    'go':
      'cmd': 'go run'
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
    'js':
      'cmd': 'phantom'
```

Note that the `source.` prefix is ignored for syntax scope listings.

Similarly, in the extension map:

```cson
'runner':
  'extensions':
    'js':
      'cmd': 'phantom'
```

### Environments

You can set `ENV` vars that will be set before scripts are run with the `env`
key.


```cson
    'ruby':
      'cmd': 'ruby'
      'env':
        'PATH': '/usr/local/rbenv/versions/2.0.0-p247/bin:$PATH'
```


Note that the `.` extension prefix is ignored for extension listings.

## License & Copyright

This package is Copyright (c) Loren Segal 2014 and is licensed under the MIT
license.
