Carrie.Helpers.Retroaction = {}

Carrie.Helpers.Retroaction.open = (id, callback) ->
  answer = Carrie.Models.Retroaction.Answer.findOrCreate(id)
  answer = new Carrie.Models.Retroaction.Answer(id: id) if not answer
  answer.clear()
  answer.set('id', id)

  answer.fetch
    async: false
    success: (model, response, options) =>
      view = new Carrie.Views.Retroaction.Answer(model: answer, callback: callback).render().el
      MathJax.Hub.Queue(["Typeset",MathJax.Hub, view])
      $(view).modal('show')
    error: (model, response, options) ->
      Carrie.Helpers.Notifications.Top.success 'Não foi possível retroagir a essa resposta!', 4000


