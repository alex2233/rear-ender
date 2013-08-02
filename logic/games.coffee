#
# Games listing/setup/joining
#

nedb = require 'nedb'

games = new nedb()
games.ensureIndex { fieldName: 'title', unique: true }

list_games = (request, response, next) ->
  games.find { finished: false }, (err, docs) ->
    request.games = (parsegame doc for doc in docs)
    next()

flush_games = (request, response, next) ->
  games.remove { finished: true }, (err, removed) ->
    request.admin.purged.games = removed
    next()

exports.defines =
  { 'list games': list_games
  , 'flush games': flush_games
  }

# Routes

route_get = (request, response) ->
  response.render 'games', { title: 'Express', users: request.users ? {}, games: request.games ? {} }

exports.addroutes = (router) ->
  router.get '/games'
           , 'verify nickname'
           , 'list users'
           , 'list games'
           , route_get
