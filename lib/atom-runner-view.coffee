{ScrollView} = require 'atom-space-pen-views'
AnsiToHtml = require 'ansi-to-html'

module.exports =
class AtomRunnerView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({title, output, footer}) ->
    view = new AtomRunnerView(title)
    view._output.html(output)
    view._footer.html(footer)
    view

  @content: ->
    @div class: 'atom-runner', tabindex: -1, =>
      @h1 'Atom Runner'
      @pre class: 'output'
      @div class: 'footer'

  constructor: (title) ->
    super

    @_output = @find('.output')
    @_footer = @find('.footer')
    @setTitle(title)

  serialize: ->
    deserializer: 'AtomRunnerView'
    title: @title
    output: @_output.html()
    footer: @_footer.html()

  getTitle: ->
    "Atom Runner: #{@title}"

  setTitle: (title) ->
    @title = title
    @find('h1').html(@getTitle())

  clear: ->
    @_output.html('')
    @_footer.html('')

  append: (text, className) ->
    span = document.createElement('span')
    node = document.createTextNode(text)
    span.appendChild(node)
    span.innerHTML = new AnsiToHtml().toHtml(span.innerHTML)
    span.className = className || 'stdout'
    @_output.append(span)

  footer: (text) ->
    @_footer.html(text)
