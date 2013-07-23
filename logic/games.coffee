#
# Games listing/setup/joining
#

nedb = require 'nedb'

games = new nedb()
games.ensureIndex { fieldName: 'title', unique: true }

list_games = (request, response) ->
  console.log request.users ? {}
  console.log request.games ? {}
  response.render 'games', { title: 'Express', users: request.users ? {}, games: request.games ? {} }

exports.addroutes = (router) ->
  router.get '/games'
           , 'verify nickname'
           , 'list users'
           , list_games
