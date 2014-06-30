Carrie.Helpers.Session = {}

Carrie.Helpers.Session.notExists = (data) ->
  data.message = 'Você já está logado' unless data.message
  if Carrie.currentUser
    Backbone.history.navigate('')
    Carrie.Helpers.Notifications.Top.success(data.message, 6000)
  else
    data.func.call()

Carrie.Helpers.Session.Exists = (data) ->
  data.message = 'Você Precisa estar logado para acessar esta página' unless data.message
  unless Carrie.currentUser
    Carrie.Helpers.Session.pageBeforeLogin = Backbone.history.fragment
    Backbone.history.navigate('/users/sign-in', true)
    Carrie.Helpers.Notifications.Top.error(data.message, 6000)
  else
    data.func.call()
