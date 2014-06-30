Carrie.Utils.Menu =
  highlight: (link) ->
    obj = $("\##{link}")

    $('ul#side-menu li').removeClass('active')
    $('ul#side-menu > li > ul.sub-menu').hide()

    if obj.length != 0
      obj.parent().addClass('active')

    $('ul#side-menu > li > ul.sub-menu:has(li.active)').show()
    return obj


Carrie.CKEDITOR =
  clear: ->
    $.each CKEDITOR.instances, (i, editor) ->
      try
        editor.destroy()
      catch error
        #console.log error

  clearWhoHas: (key) ->
    $.each CKEDITOR.instances, (i, editor) ->
      try
        if editor.name.search(key) != -1
          editor.destroy()
      catch error
        #console.log error

  show: (el, config) ->
    el = '#ckeditor' unless el
    unless config
      config =
        language: 'pt-br',
        toolbar: Carrie.CKEDITOR.toolbar.full
        extraPlugins: 'tliyoutube'
        scayt_autoStartup: true
        allowedContent: true

    setTimeout ( ->
      $(el).ckeditor(config)
    ), 100

  toolbar:
    basic:
      [
        { name: 'document', items : [ 'Source','-', 'NewPage','Preview' ] },
          { name: 'basicstyles', items : [ 'Bold','Italic' ] },
          { name: 'styles',  items : [ 'Styles','Format','Font','FontSize' ] }
          { name: 'paragraph', items : [ 'NumberedList','BulletedList', '-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock', '-', 'Underline','Strike','Subscript','Superscript' ] },
          { name: 'links',  items : [ 'Link','Unlink','Anchor' ] },
          { name: 'tools', items : [ 'Maximize','-','About' ] },
          { name: 'insert', items : [ 'Image', 'Table','HorizontalRule'] },
          { name: 'colors', items : [ 'TextColor','BGColor' ] }
      ]
    full:
      [
        { name: 'document',    items : [ 'Source','-','NewPage','DocProps','Preview','Print','-','Templates' ] },
        { name: 'clipboard',   items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
        { name: 'editing',     items : [ 'Find','Replace','-','SelectAll','-','SpellChecker', 'Scayt' ] },
        { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
        { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
        { name: 'links',       items : [ 'Link','Unlink','Anchor' ] },
        { name: 'insert',      items : [ 'Image', 'Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak', 'Frame' ] },
        '/',
        { name: 'styles',      items : [ 'Styles','Format','Font','FontSize' ] },
        { name: 'colors',      items : [ 'TextColor','BGColor' ] },
        { name: 'tools',       items : [ 'Maximize', 'ShowBlocks','-','About' ] },
        { name: 'Video',       items : [ 'tliyoutube' ] }
      ]

Carrie.Bootstrap =
  popoverPlacement: ->
    width = $(window).width()
    if width >= 500
      return 'right'
    else
      return 'bottom'

Carrie.Utils.Loading = (obj) ->
  obj.on 'fetch', ->
    $('.loading').show()
  , obj
  obj.on 'reset', ->
    $('.loading').hide()
  , obj
  obj.on 'change', ->
    $('.loading').hide()
  , obj

Carrie.Utils.Pluralize = (amount, word_s, word_p) ->
  s = amount
  if amount == 1
    s = "#{s} #{word_s}"
  else
    s = "#{s} #{word_p}"
  s

Carrie.Utils.clearBackboneRelationalCache = ->
  oldReverseRelations = Backbone.Relational.store._reverseRelations
  Backbone.Relational.store = new Backbone.Store()
  Backbone.Relational.store._reverseRelations = oldReverseRelations
  Backbone.Relational.eventQueue = new Backbone.BlockingQueue()
