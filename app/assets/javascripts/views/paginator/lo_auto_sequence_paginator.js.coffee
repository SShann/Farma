class Carrie.Published.Views.LoAutoSequencePaginator extends Backbone.Marionette.ItemView
  template: 'paginator/lo_published'
  tagName: 'div'
  className: 'lo-paginator pagination pagination-centered'

  initialize: ->
    @model.bind 'reset', @render, this
    @length = @model.get('pages_count')
    @page = 0
    @page = @options.page unless (@options.page < 0 || @options.page >= @length)
    @parentView = @options.parentView
    @team = @options.team
    @team_id = @team.get('id') if @team

  events:
    'change #page-select': 'changePage'
    'click #next-page': 'nextPage'
    'click #prev-page': 'prevPage'
    #'click #last-page': 'lastPage'
    #'click #first-page': 'firstPage'

  changePage: (ev) ->
    ev.preventDefault()
    @page = parseInt($(ev.target).val())
    @showPage()

  firstPage: (ev) ->
    ev.preventDefault()
    @page = 0
    @showPage()

  lastPage: (ev) ->
    ev.preventDefault()
    @page = @length-1
    @showPage()

  nextPage: (ev) ->
    ev.preventDefault()
    if @page+1 < @length
      @page += 1
      @showPage()

  prevPage: (ev) ->
    ev.preventDefault()
    if @page > 0
      @page -= 1
      @showPage()

  modelType: ->
    $(@el).find('select#page-select option:selected').data('type')

  pageCollection: ->
    $(@el).find('select#page-select option:selected').data('page-collection')

  showPage: (type) ->
    $(@el).find('select#page-select').val(@page)

    @setBreadcrumb()
    data = @model.get('contents')[@pageCollection()]

    if @modelType() is 'introduction'
      model = Carrie.Published.Models.Introduction.findOrCreate(data)
      model = new Carrie.Published.Models.Introduction(data) unless model

      view = new Carrie.Published.Views.Introduction
        model: model
    else
      model = Carrie.Published.Models.Exercise.findOrCreate(data)
      model = new Carrie.Published.Models.Exercise(data) unless model
      view = new Carrie.Published.Views.Exercise
        model: model
        team_id: @team_id
        paginator: @

    $(@parentView.el).find('section.page').html(view.render().el)

  setBreadcrumb: ->
    bread = ''
    bread = "#{@team.get('name')} /" if @team
    url = @model.get('url_page')

    if @page != 0
      url += "/pages/#{@page+1}"

    Backbone.history.navigate(url, false)

    Carrie.layouts.main.reloadBreadcrumb()
    Carrie.layouts.main.addBreadcrumb('Turmas Matriculas', '/teams/enrolled', true) if @team
    bread = "#{bread} Objeto de aprendizagem #{@model.get('name')} / #{@model.get('pages')[@page].page_name}"
    Carrie.layouts.main.addBreadcrumb(bread, '', false)

  onRender: ->
    @showPage()

  # Change for auto sequence
  goToNextPage: ->
    url = @model.get('url_page')
    url += "/pages/#{@length+1}"
    console.log url
    Backbone.history.navigate(url, true)

  # Change for auto sequence
  # CanAnswer if is the last page
  canAnswer: ->
    return (@page == @length-1)
