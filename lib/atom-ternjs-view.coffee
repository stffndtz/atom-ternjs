{$, $$, SelectListView} = require 'atom'

module.exports =
class AtomTernjsView extends SelectListView

  bufferWasEmpty = true
  buffer = false

  constructor: (serializeState) ->
    # Create root element
    super
    bufferWasEmpty = true
    buffer = @filterEditorView.getEditor().getBuffer()
    @addClass 'atom-ternjs text-normal'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  cancelled: ->
    super
    @trigger 'completed'
    @unregisterEvents()

  viewForItem: ({name, type}) ->
    $$ ->
      @li =>
        @span "#{name} : #{type}"

  confirmed: (item) ->
    @trigger 'completed', item
    @cancel()

  registerEvents: ->
    @filterEditorView.on 'keyup.ternjs', (e) =>
      if e.which is 8 and bufferWasEmpty
        @cancel()
      else
        bufferWasEmpty = false
      bufferWasEmpty = buffer.isEmpty()

  unregisterEvents: ->
    @filterEditorView.off 'keyup.ternjs'

  handleEvents: ->
    @editorView.off 'tern:next'
    @editorView.off 'tern:previous'
    @editorView.on 'tern:next', => @selectNextItemView()
    @editorView.on 'tern:previous', => @selectPreviousItemView()

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false

  getFilterKey: -> 'name'

  # Taken from https://atom.io/packages/autocomplete-plus
  setPosition: ->
    { left, top } = @editorView.pixelPositionForScreenPosition(@editor.getCursorScreenPosition())
    cursorLeft = left
    cursorTop = top

    # The top position if we would put it below the current line
    # put it right into the line
    belowPosition = cursorTop
    #@editorView.lineHeight

    # The top position of the lower edge if we would put it below the current line
    belowLowerPosition = belowPosition + @outerHeight()

    # The position if we would put it above the line
    abovePosition = cursorTop

    if belowLowerPosition > @editorView.outerHeight() + @editorView.scrollTop()
      # We can't put it below - put it above. Using CSS transforms to
      # move it 100% up so that the lower edge is above the current line
      @css left: cursorLeft, top: abovePosition
      @css '-webkit-transform', 'translateY(-100%)'
    else
      # We can put it below, remove possible previous CSS transforms
      @css left: cursorLeft, top: cursorTop
      @css '-webkit-transform', ''

    console.log @editorView.lineHeight

  afterAttach: (onDom) ->
    if onDom
      @registerEvents()
      widestCompletion = parseInt(@css('min-width')) or 0
      @list.find('span').each ->
        widestCompletion = Math.max(widestCompletion, $(this).outerWidth())
      @list.width(widestCompletion)
      @width(@list.outerWidth())

  startCompletion: (completions)  ->

    if atom.config.get('atom-ternjs.inlineCompletion')
      @addClass 'inline'
    else
      @addClass 'popover-list'
    console.log atom.config.get('atom-ternjs.inlineCompletion')
    @setItems(completions)
    @editorView = atom.workspaceView.getActivePaneView().activeView
    @editorView?.appendToLinesView(this)
    @editor = @editorView?.getEditor()
    @setPosition()
    @handleEvents()
    @focusFilterEditor()
