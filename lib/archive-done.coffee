{Disposable, CompositeDisposable} = require 'atom'

module.exports = ArchiveDone =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'birch-outline-editor',
      'archive-done:archive': => @archive()

  consumeBirchOutlineEditorService: (birchOutlineEditorService) ->
    @birchOutlineEditorService = birchOutlineEditorService
    new Disposable =>
      @birchOutlineEditorService = null

  deactivate: ->
    @subscriptions.dispose()

  archive: ->
    outline = @birchOutlineEditorService?.getActiveOutlineEditor()?.outline
    if outline
      outline.beginUpdates()

      archive = outline.itemsForXPath("//p/b[text()='Archive']")[0]
      unless archive
        archive = outline.createItem 'Archive'
        archive.addElementInBodyTextRange 'B', {}, 0, 7
        outline.root.appendChild archive

      items = outline.itemsForXPath "//li[@data-done]"
      items = @birchOutlineEditorService.Item.commonAncestors(items)
      items = items.filter (each) ->
        each != archive and not archive.contains each

      if items.length
        archive.insertChildrenBefore items, archive.firstChild

      outline.endUpdates()
