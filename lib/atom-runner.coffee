spawn = require('child_process').spawn
fs = require('fs')
url = require('url')

AtomRunnerView = require './atom-runner-view'

module.exports =
  extensionMap: null
  scopeMap: null

  defaultExtensionMap:
    'spec.coffee': 'jasmine-node --coffee'

  defaultScopeMap:
    coffee: 'coffee'
    js: 'node'
    ruby: 'ruby'
    python: 'python'

  activate: ->
    @runnerView = null
    atom.workspaceView.command 'runner:run', => @run()
    atom.workspaceView.command 'runner:stop', => @stop()

  run: ->
    @loadConfig()
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    path = editor.getPath()
    cmd = @commandFor(editor)
    unless cmd?
      console.warn("No registered executable for file '#{path}'")
      return

    previousPane = atom.workspaceView.getActivePaneView()
    if not @runnerView? or atom.workspaceView.find('.atom-runner').size() == 0
      @runnerView = new AtomRunnerView(editor.getTitle())
      panes = atom.workspaceView.getPaneViews()
      @pane = panes[panes.length - 1].splitRight(@runnerView)

    @runnerView.setTitle(editor.getTitle())
    if @pane and @pane.isOnDom()
      @pane.activateItem(@runnerView)
    @execute(cmd, editor)
    previousPane.activate()

  stop: ->
    if @child
      @child.kill()
      @child = null
      if @runnerView
        @runnerView.append('^C', 'stdin')

  runnerView: null
  pane: null

  execute: (cmd, editor) ->
    @stop()
    @runnerView.clear()

    args = if editor.getPath() then [editor.getPath()] else []
    splitCmd = cmd.split(/\s+/)
    if splitCmd.length > 1
      cmd = splitCmd[0]
      args = splitCmd.slice(1).concat(args)
    @child = spawn(cmd, args, cwd: atom.project.path)
    @child.stderr.on 'data', (data) =>
      @runnerView.append(data, 'stderr')
    @child.stdout.on 'data', (data) =>
      @runnerView.append(data, 'stdout')
    @child.on 'close', (code, signal) =>
      @runnerView.footer('Exited with code=' + code + ' in ' +
        ((new Date - startTime) / 1000) + ' seconds')
      @child = null

    startTime = new Date
    unless editor.getPath()?
      @child.stdin.write(editor.getText())
    @child.stdin.end()
    @runnerView.footer('Running: ' + cmd + ' ' + editor.getPath())

  loadConfig: ->
    @scopeMap = atom.config.get('runner.scopes')
    unless @scopeMap?
      @scopeMap = atom.config.set('runner.scopes', @defaultScopeMap)

    @extensionMap = atom.config.get('runner.extensions')
    unless @extensionMap?
      @extensionMap = atom.config.set('runner.extensions', @defaultExtensionMap)

  commandFor: (editor) ->
    # try to lookup by extension
    if editor.getPath()?
      for ext in Object.keys(@extensionMap)
        if editor.getPath().match('\\.' + ext + '$')
          return @extensionMap[ext]

    # lookup by grammar
    scope = editor.getCursorScopes()[0]
    for name in Object.keys(@scopeMap)
      if scope.match('^source\\.' + name + '\\b')
        return @scopeMap[name]
