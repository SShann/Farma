class Carrie.Published.Views.Lo extends Backbone.Marionette.ItemView
  template: 'published/los/show'
  tagName: 'section'

  initialize: ->
    @paginator = new Carrie.Published.Views.LoPaginator
      model: @model
      parentView: @
      page: @options.page-1 || 0
      team: @model.get('team')
      retroaction_id: @options.retroaction_id

  onRender: ->
    @el.id = @model.get('id')
    if @model.get('pages_count') > 0
      $(@el).find('.navigator').html(@paginator.render().el)
    else
      Carrie.layouts.main.reloadBreadcrumb()
      if @model.get('team')
        team =  "Turma #{@model.get('team').get('name')} / "
      else
        team = ""

      bread = "#{team} Objeto de aprendizagem #{@model.get('name')}"
      Carrie.layouts.main.addBreadcrumb(bread, '', false)

      $(@el).find('.page').html('Objeto de aprendizagem sem publicações')
