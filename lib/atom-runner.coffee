{ConfigObserver} = require 'atom'

spawn = require('child_process').spawn
fs = require('fs')
url = require('url')
p = require('path')

AtomRunnerView = require './atom-runner-view'

class AtomRunner
  cfg:
    ext: 'runner.extensions'
    scope: 'runner.scopes'

  defaultExtensionMap:
    'spec.coffee': 'mocha'

  defaultScopeMap:
    coffee: 'coffee'
    js: 'node'
    ruby: 'ruby'
    python: 'python'
    go: 'go run'
    shell: 'bash'

  extensionMap: null
  scopeMap: null

  debug: (args...) ->
    console.debug('[atom-runner]', args...)

  initEnv: ->
    if process.platform == 'darwin'
      [shell, out] = [process.env.SHELL || 'bash', '']
      @debug('Importing ENV from', shell)
      pid = spawn(shell, ['--login', '-c', 'env'])
      pid.stdout.on 'data', (chunk) -> out += chunk
      pid.on 'error', =>
        @debug('Failed to import ENV from', shell)
      pid.on 'close', =>
        for line in out.split('\n')
          match = line.match(/^(\S+?)=(.+)/)
          process.env[match[1]] = match[2] if match
      pid.stdin.end()

  destroy: ->
    atom.config.unobserve @cfg.ext
    atom.config.unobserve @cfg.scope

  activate: ->
    @initEnv()
    atom.config.setDefaults @cfg.ext, @defaultExtensionMap
    atom.config.setDefaults @cfg.scope, @defaultScopeMap
    atom.config.observe @cfg.ext, =>
      @extensionMap = atom.config.get(@cfg.ext)
    atom.config.observe @cfg.scope, =>
      @scopeMap = atom.config.get(@cfg.scope)
    atom.workspaceView.command 'run:file', => @run(false)
    atom.workspaceView.command 'run:selection', => @run(true)
    atom.workspaceView.command 'run:stop', => @stop()
    atom.workspaceView.command 'run:close', => @stopAndClose()

  run: (selection) ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    path = editor.getPath()
    cmd = @commandFor(editor)
    unless cmd?
      console.warn("No registered executable for file '#{path}'")
      return

    {pane, view} = @runnerView()
    if not view?
      view = new AtomRunnerView(editor.getTitle())
      panes = atom.workspaceView.getPaneViews()
      pane = panes[panes.length - 1].splitRight(view)

    view.setTitle(editor.getTitle())
    pane.activateItem(view)
    @execute(cmd, editor, view, selection)

  stop: (view) ->
    if @child
      view ?= @runnerView().view
      if view and view.isOnDom()?
        view.append('^C', 'stdin')
      else
        @debug('Killed child', child.pid)
      @child.kill('SIGINT')
      if @child.killed
        @child = null

  stopAndClose: ->
    {pane, view} = @runnerView()
    pane?.removeItem(view)
    @stop(view)

  execute: (cmd, editor, view, selection) ->
    view.clear()
    @stop()

    args = []
    if editor.getPath()
      editor.save()
      args.push(editor.getPath()) if !selection
    splitCmd = cmd.split(/\s+/)
    if splitCmd.length > 1
      cmd = splitCmd[0]
      args = splitCmd.slice(1).concat(args)
    try
      dir = atom.project.path || '.'
      if not fs.statSync(dir).isDirectory()
        dir = p.dirname(dir)
      @child = spawn(cmd, args, cwd: dir)
      @child.on 'error', (err) =>
        view.append(err.stack, 'stderr')
        view.scrollToBottom()
        @child = null
      @child.stderr.on 'data', (data) =>
        view.append(data, 'stderr')
        view.scrollToBottom()
      @child.stdout.on 'data', (data) =>
        view.append(data, 'stdout')
        view.scrollToBottom()
      @child.on 'close', (code, signal) =>
        view.footer('Exited with code=' + code + ' in ' +
          ((new Date - startTime) / 1000) + ' seconds')
        @child = null
    catch err
      view.append(err.stack, 'stderr')
      view.scrollToBottom()
      @stop()

    startTime = new Date
    if selection
      @child.stdin.write(editor.getSelection().getText())
    else if !editor.getPath()
      @child.stdin.write(editor.getText())
    @child.stdin.end()
    view.footer('Running: ' + cmd + ' ' + editor.getPath())

  commandFor: (editor) ->
    # try to find a shebang
    shebang = @commandForShebang(editor)
    return shebang if shebang?

    # try to lookup by extension
    if editor.getPath()?
      for ext in Object.keys(@extensionMap).sort((a,b) -> b.length - a.length)
        if editor.getPath().match('\\.' + ext + '$')
          return @extensionMap[ext]

    # lookup by grammar
    scope = editor.getCursorScopes()[0]
    for name in Object.keys(@scopeMap)
      if scope.match('^source\\.' + name + '\\b')
        return @scopeMap[name]

  commandForShebang: (editor) ->
    match = editor.lineForBufferRow(0).match(/^#!\s*(.+)/)
    match and match[1]

  runnerView: ->
    for pane in atom.workspaceView.getPaneViews()
      for view in pane.getItems()
        return {pane: pane, view: view} if view instanceof AtomRunnerView
    {pane: null, view: null}


module.exports = new AtomRunner
