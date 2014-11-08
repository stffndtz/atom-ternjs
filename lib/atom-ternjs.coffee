AtomTernjsView = require './atom-ternjs-view'
TernServerFactory = require './atom-ternjs-server'
ClientFactory = require './atom-ternjs-client'
_ = require 'underscore-plus'

client = null;
module.exports =
  activate: (state) ->
    @atomTernjsView = new AtomTernjsView(state.atomTernjsViewState)
    @atomTernjsView.on 'completed', (evt, data) =>
      if (data?.name)
        start = [@start.line, @start.ch]
        end = [@end.line, @end.ch]
        atom.workspace.getActiveEditor().getBuffer().setTextInRange [start, end], (data.name || 'asd')
      @registerEvents()

    atom.workspace.onDidAddTextEditor ({item, pane, index}) =>
      @registerEditor(pane.items[index])

    @startServer()
    @registerEvents()

  deactivate: ->
    @stopServer()
    @atomTernjsView.destroy()

  serialize: ->
    atomTernjsViewState: @atomTernjsView.serialize()

  update: (editor) ->
    if client
      client.update editor.getUri(), editor.getText()

  isInString: (editor, cursor)->
    scopes = editor.scopeDescriptorForBufferPosition(cursor.getBufferPosition()).scopes
    if 'string.quoted.single.js' not in scopes and 'string.quoted.double.js' not in scopes
      return false
    else
      return true

  checkCompletion: (editor, force = false) ->
    cursor = editor.getCursor()

    if @isInString(editor, cursor)
      console.log 'skip -> cursor is inside string'
      return

    prefix = cursor.getCurrentWordPrefix()
    if prefix[prefix.length - 1] is '.' or force is yes
      row = cursor.getBufferRow()
      col = cursor.getBufferColumn()
      client.completions(editor.getUri(),
        line: row
        ch: col
      editor.getText()).then (data) =>
        if data.completions.length
          {@start, @end} = data
          @atomTernjsView.startCompletion(data.completions)
      , (err) ->
        console.error 'error', err

  registerEvents: ->
    atom.workspace.eachEditor (editor) =>
      @registerEditor (editor)

  registerEditor: (editor) ->
    if editor.getGrammar().name isnt 'JavaScript'
      return
    buffer = editor.getBuffer()
    buffer.on 'contents-modified', _.throttle @update.bind(this, editor), 2000
    buffer.on 'contents-modified', @checkCompletion.bind(this, editor, false)

  unregisterEvents: ->
    atom.workspace.eachEditor (editor) =>
      if editor.getGrammar().name isnt 'JavaScript'
        return
      buffer = editor.getBuffer()
      buffer.off 'contents-modified'

  startServer: ->
    if @server?.process
      return
    @server = new TernServerFactory()
    @server.start (port) =>
      @ternPort = port
      client = new ClientFactory(port)
      atom.workspaceView.command "tern:completion", => @checkCompletion(atom.workspace.getActiveEditor(), yes)

  stopServer: ->
    unless @server?.process
      return
    atom.workspaceView.command "tern:completion", => null
    @unregisterEvents()
    @server.stop()