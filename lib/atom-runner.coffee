{ConfigObserver} = require 'atom'

spawn = require('child_process').spawn
fs = require('fs')
url = require('url')
p = require('path')

AtomRunnerView = require './atom-runner-view'

class AtomRunner
  config:
    showOutputWindow:
      title: 'Show Output Pane'
      description: 'Displays the output pane when running commands. Uncheck to hide output.'
      type: 'boolean'
      default: true
      order: 1
    paneSplitDirection:
      title: 'Pane Split Direction'
      description: 'The direction to split when opening the output pane.'
      type: 'string'
      default: 'Right'
      enum: ['Right', 'Down', 'Up', 'Left']

  cfg:
    ext: 'runner.extensions'
    scope: 'runner.scopes'

  defaultExtensionMap:
    'spec.coffee': 'mocha'
    'ps1': 'c:\\windows\\sysnative\\windowspowershell\\v1.0\\powershell.exe -file'
    '_test.go': 'go test'

  defaultScopeMap:
    coffee: 'coffee'
    js: 'node'
    ruby: 'ruby'
    python: 'python'
    go: 'go run'
    shell: 'bash'
    powershell: 'c:\\windows\\sysnative\\windowspowershell\\v1.0\\powershell.exe -noninteractive -noprofile -c -'

  extensionMap: null
  scopeMap: null
  splitFuncDefault: 'splitRight'
  splitFuncs:
    Right: 'splitRight'
    Left: 'splitLeft'
    Up: 'splitUp'
    Down: 'splitDown'

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
    atom.commands.add 'atom-workspace', 'run:file', => @run(false)
    atom.commands.add 'atom-workspace', 'run:selection', => @run(true)
    atom.commands.add 'atom-workspace', 'run:stop', => @stop()
    atom.commands.add 'atom-workspace', 'run:close', => @stopAndClose()
    atom.commands.add '.atom-runner', 'run:copy', =>
      atom.clipboard.write(window.getSelection().toString())

  run: (selection) ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    path = editor.getPath()
    cmd = @commandFor(editor, selection)
    unless cmd?
      console.warn("No registered executable for file '#{path}'")
      return

    if atom.config.get('atom-runner.showOutputWindow')
      {pane, view} = @runnerView()
      if not view?
        view = new AtomRunnerView(editor.getTitle())
        panes = atom.workspace.getPanes()
        dir = atom.config.get('atom-runner.paneSplitDirection')
        dirfunc = @splitFuncs[dir] || @splitFuncDefault
        pane = panes[panes.length - 1][dirfunc](view)
    else
      view =
        mocked: true
        append: (text, type) ->
          if type == 'stderr'
            console.error(text)
          else
            console.log(text)
        scrollToBottom: ->
        clear: ->
        footer: ->

    unless view.mocked
      view.setTitle(editor.getTitle())
      pane.activateItem(view)

    @execute(cmd, editor, view, selection)

  stop: (view) ->
    if @child
      view ?= @runnerView().view
      if view and view.isOnDom()?
        view.append('^C', 'stdin')
      else
        @debug('Killed child', @child.pid)
      @child.kill('SIGINT')
      if @child.killed
        @child = null

  stopAndClose: ->
    {pane, view} = @runnerView()
    pane?.removeItem(view)
    @stop(view)

  execute: (cmd, editor, view, selection) ->
    @stop()
    view.clear()

    args = []
    if editor.getPath()
      editor.save()
      args.push(editor.getPath()) if !selection
    splitCmd = cmd.split(/\s+/)
    if splitCmd.length > 1
      cmd = splitCmd[0]
      args = splitCmd.slice(1).concat(args)
    try
      dir = atom.project.getPaths()[0] || '.'
      try
        if not fs.statSync(dir).isDirectory()
          throw new Error("Bad dir")
      catch
        dir = p.dirname(dir)
      @child = spawn(cmd, args, cwd: dir)
      currentPid = @child.pid
      @child.on 'error', (err) =>
        if err.message.match(/\bENOENT$/)
          view.append('Unable to find command: ' + cmd + '\n', 'stderr')
          view.append('Are you sure PATH is configured correctly?\n\n', 'stderr')
          view.append('ENV PATH: ' + process.env.PATH + '\n\n', 'stderr')
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
        if @child && @child.pid == currentPid
          time = ((new Date - startTime) / 1000)
          view.footer("Exited with code=#{code} in #{time} seconds")
          view.scrollToBottom()
    catch err
      view.append(err.stack, 'stderr')
      view.scrollToBottom()
      @stop()

    startTime = new Date
    if selection
      @child.stdin.write(editor.getLastSelection().getText())
    else if !editor.getPath()
      @child.stdin.write(editor.getText())
    @child.stdin.end()
    view.footer("Running: #{cmd} #{editor.getPath()} (pid #{@child.pid})")

  commandFor: (editor, selection) ->
    # try to find a shebang
    shebang = @commandForShebang(editor)
    return shebang if shebang?

    # Don't lookup by extension from selection.
    if (!selection)
      # try to lookup by extension
      if editor.getPath()?
        for ext in Object.keys(@extensionMap).sort((a,b) -> b.length - a.length)
          boundary = if ext.match(/^\b/) then '' else '\\b'
          if editor.getPath().match(boundary + ext + '$')
            return @extensionMap[ext]

    # lookup by grammar
    scope = editor.getLastCursor().getScopeDescriptor().scopes[0]
    for name in Object.keys(@scopeMap)
      if scope.match('^source\\.' + name + '\\b')
        return @scopeMap[name]

  commandForShebang: (editor) ->
    match = editor.lineTextForBufferRow(0).match(/^#!\s*(.+)/)
    match and match[1]

  runnerView: ->
    for pane in atom.workspace.getPanes()
      for view in pane.getItems()
        return {pane: pane, view: view} if view instanceof AtomRunnerView
    {pane: null, view: null}


module.exports = new AtomRunner
