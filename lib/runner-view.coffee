{ScrollView} = require 'atom'

module.exports =
class RunnerView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({title, output, footer}) ->
    view = new RunnerView(title)
    view._output.html(output)
    view._footer.html(footer)
    view

  @content: ->
    @div class: 'atom-runner-content', =>
      @h1 'Atom Runner'
      @pre class: 'output'
      @div class: 'footer'

  constructor: (title) ->
    super
    @_output = @find('.output')
    @_footer = @find('.footer')
    @setTitle(title)

  serialize: ->
    deserializer: 'RunnerView'
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
    span.className = className || 'stdout'
    @_output.append(span)

  footer: (text) ->
    @_footer.html(text)
