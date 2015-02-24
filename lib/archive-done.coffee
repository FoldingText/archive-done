{Disposable, CompositeDisposable} = require 'atom'

module.exports = ArchiveDone =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'archive-done:toggle': => @toggle()

  consumeOutlineEditorService: (outlineEditorService) ->
    @outlineEditorService = outlineEditorService
    new Disposable =>
      @outlineEditorService = null

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    outline = @outlineEditorService?.getActiveOutlineEditor()?.outline
    if outline
      archive = outline.itemsForXPath("//p/b[text()='Archive']")[0]
      unless archive
        archive = outline.createItem 'Archive'
        archive.addElementInBodyTextRange 'b', {}, 0, 7
        outline.root.appendChild archive

      items = outline.itemsForXPath "//li[@data-done]"
      items = @outlineEditorService.Item.commonAncestors(items)
      items = items.filter (each) ->
        each != archive and not archive.contains each

      if items.length
        archive.insertChildrenBefore items, archive.firstChild