class Carrie.Views.TeamShow extends Backbone.Marionette.ItemView
  template: 'teams/each_created'
  tagName: 'article'

  events:
    'click #edit_team' : 'edit'
    'click #destroy_team' : 'destroy'
    'click .view-learners': 'viewLearners'
    'click #team_details' : 'team_details'

  initialize: ->
    @icon = 'icon-eye-close'

  team_details: (ev) ->
    ev.preventDefault()
    Backbone.history.navigate("/teams/created/#{@model.get('id')}", true)

  edit: (ev) ->
    ev.preventDefault()
    Backbone.history.navigate("/teams/edit/#{@model.get('id')}", true)

  destroy: (ev) ->
    ev.preventDefault()
    msg = "Você tem certeza que deseja remover esta turma?"

    bootbox.confirm msg, (confirmed) =>
      if confirmed
        team = Carrie.Models.Team.findOrCreate id: @model.get('id')
        team.destroy
          success: (model, response) =>
            $(@el).fadeOut(800, 'linear')

            Carrie.Helpers.Notifications.Top.success 'Turma removida com sucesso!', 4000

  viewLearners: (ev) ->
    ev.preventDefault()
    $(ev.target).find('i').removeClass(@icon)
    if @icon == 'icon-eye-close'
      @icon = 'icon-eye-open'
      $(ev.target).html('<i></i> Esconder aprendizes')
    else
      @icon = 'icon-eye-close'
      $(ev.target).html('<i></i> Ver aprendizes')

    $(ev.target).find('i').addClass(@icon)
    $(@el).find('section.show-learners').toggle()


  onRender: ->
    @el.id = @model.get('id')
