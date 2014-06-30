class Carrie.Published.Routers.Los extends Backbone.Marionette.AppRouter
  appRoutes:
    'published/los/:id': 'showPage'
    'published/los/:id/pages/:page': 'showPage'

    'published/teams/:team_id/los/:id': 'showPageWithTeam'
    'published/teams/:team_id/los/:id/pages/:page': 'showPageWithTeam'

    'published/teams/:team_id/los/:id/retroaction/:retroaction_id': 'showPageWithTeam'
    'published/teams/:team_id/los/:id/pages/:page/retroaction/:retroaction_id': 'showPageWithTeam'

class Carrie.Published.Controllers.Los

  showPage: (id, page) ->
    Carrie.Helpers.Session.Exists
      func: =>
        Carrie.Utils.Menu.highlight ''
        lo = Carrie.Published.Models.Lo.findOrCreate(id)
        lo = new Carrie.Published.Models.Lo(id: id) if not lo

        lo.fetch
          async: false
          success: (model, response, options) =>
            lo.set('url_page', "/published/los/#{lo.get('id')}")

            view = new Carrie.Published.Views.Lo(model: lo, page: page)
            Carrie.layouts.main.content.show view
            Carrie.layouts.main.hideMenu()
          error: (model, response, options) ->
            alert('Objeto de aprendizagem não encontrado!')
            Backbone.history.navigate('/my-los', true)

  showPageWithTeam: (team_id, id, page, retroaction_id) ->
    Carrie.Helpers.Session.Exists
      func: =>
        Carrie.Utils.Menu.highlight ''
        team = Carrie.Models.Team.findOrCreate(team_id)
        team = new Carrie.Models.Team(id: team_id) if not team

        lo = Carrie.Published.Models.Lo.findOrCreate(id)
        lo = new Carrie.Published.Models.Lo(id: id, team_id: team_id) if not lo

        team.fetch
          async: false
          success: (model) =>
            lo.set('team', team)
            lo.fetch
              async: false
              success: (model, response, options) =>
                lo.set('url_page', "/published/teams/#{team_id}/los/#{model.get('id')}")

                view = new Carrie.Published.Views.Lo(model: lo, page: page, team_id: team_id, retroaction_id: retroaction_id)
                Carrie.layouts.main.content.show view
                Carrie.layouts.main.hideMenu()
              error: (model, response, options) ->
                alert('Objeto de aprendizagem não encontrado!')
                Backbone.history.navigate('/teams/enrolled', true)

          error: (model, response, options) ->
            alert('Turma não encontrada!')
            Backbone.history.navigate('/teams/enrolled', true)
