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
    @addClass 'atom-ternjs popover-list'

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
    @detach()

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

  # Returns an object that can be retrieved when package is activated
  setPosition: ->
    { left, top } = @editorView.pixelPositionForScreenPosition(@editor.getCursorScreenPosition())
    height = @outerHeight()
    potentialTop = top + @editorView.lineHeight
    potentialBottom = potentialTop - @editorView.scrollTop() + height
    if @aboveCursor or potentialBottom > @editorView.outerHeight()
      @aboveCursor = true
      @css(left: left, top: top - height, bottom: 'inherit')
    else
      @css(left: left, top: potentialTop, bottom: 'inherit')

  afterAttach: (onDom) ->
    if onDom
      @registerEvents()
      widestCompletion = parseInt(@css('min-width')) or 0
      @list.find('span').each ->
        widestCompletion = Math.max(widestCompletion, $(this).outerWidth())
      @list.width(widestCompletion)
      @width(@list.outerWidth())

  startCompletion: (completions)  ->
    @setItems completions
    if !@hasParent()
      # atom.workspaceView.append(this)
      @editorView = atom.workspaceView.getActivePaneView().activeView
      @editorView?.appendToLinesView(this)
      @editor = @editorView?.getEditor()
      @setPosition()
      @handleEvents()
      @focusFilterEditor()
