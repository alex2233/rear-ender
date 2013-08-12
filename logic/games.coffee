#
# Games listing/setup/joining
#

nedb = require 'nedb'

games = new nedb()
games.ensureIndex { fieldName: 'title', unique: true }

list_games = (request, response, next) ->
  games.find { finished: false }, (err, docs) ->
    filter = (doc) ->
      gamename: doc.gamename
      password: doc.password
      factions: doc.factions
    request.games = (filter doc for doc in docs)
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

list_get = (request, response) ->
  response.render 'games',
    title: 'Games List - '
    games: request.games ? {}

create_get = (request, response) ->
  response.render 'game_create',
    title: 'Create Game - '
    games: request.games ? {}
    factions: GLOBAL.db.factions

exports.addroutes = (router) ->
  router.get '/games'
           , 'verify nickname'
           , 'list games'
           , list_get

  router.get '/games/create'
           , 'verify nickname'
           , 'list games'
           , create_get
