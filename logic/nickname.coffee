#
# NickName handling
#

nedb = require 'nedb'

recentlyseen = new nedb()
recentlyseen.ensureIndex { fieldName: 'unique', unique: true }

# 60 minutes = 1 hour
# 60 seconds = 1 minute
# 1000 milliseconds = 1 second
# 1 hour in milliseconds

timeout = 60 * 60 * 1000

flush_users = (request, response, next) ->
  recentlyseen.remove { lastseen: { $lt: (Date.now() - timeout) } }, (err, removed) ->
    request.admin.purged.users = removed
    next()

list_users = (request, response, next) ->
  recentlyseen.find { lastseen: { $gte: (Date.now() - timeout) } }, (err, docs) ->
    filter = (doc) ->
      nickname: doc.nickname
      tripcode: doc.tripcode
      lastseen: doc.lastseen
    request.users = (filter doc for doc in docs)
    next()

ping_user = (nickname, triphash) ->
  recentlyseen.update
    unique: "#{triphash},#{nickname}"
  ,
    $set:
      lastseen: Date.now()
  ,
    upsert: true
  ,
    (err, numReplaced, upserted) ->
      if upserted
        if triphash is ''
          tripcode = ''
          console.log "First sighting of #{nickname}... (no tripcode)"
        else
          hmac = require('crypto').createHmac 'sha384', GLOBAL.config.uuids.hmacsalt
          hmac.update GLOBAL.config.uuids.hashiv
          hmac.update nickname
          hmac.update GLOBAL.config.uuids.hashsv
          hmac.update triphash
          hmac.update GLOBAL.config.uuids.hashtv
          tripcode = hmac.digest('base64')[1..8]
          console.log "First sighting of #{nickname},#{triphash[1..10]}... (generated tripcode #{tripcode})"

        recentlyseen.update
          unique: "#{triphash},#{nickname}"
        ,
          $set:
            tripcode: tripcode
            nickname: nickname
      else
        if triphash is ''
          console.log "Return visit from #{nickname}..."
        else
          console.log "Return visit from #{nickname},#{triphash[1..10]}..."

verify_nickname = (request, response, next) ->
  if request.signedCookies.nickname?
    request.nickname = request.signedCookies.nickname
    request.triphash = request.signedCookies.triphash ? ''
    ping_user request.nickname, request.triphash
  else
    response.redirect '/nickname'
  next()

route_get = (request, response) ->
  response.render 'nickname', { title: 'Enter Nickname - ' }

route_post = (request, response) ->
  if request.body.nickname? isnt ''
    response.cookie 'nickname', request.body.nickname, { signed: true, httpOnly: true }
    if request.body.tripcode ? false
      hmac = require('crypto').createHmac 'sha384', GLOBAL.config.uuids.hmacsalt
      hmac.update GLOBAL.config.uuids.hashiv
      hmac.update request.body.nickname
      hmac.update GLOBAL.config.uuids.hashsv
      hmac.update request.body.tripcode
      hmac.update GLOBAL.config.uuids.hashtv
      triphash = hmac.digest 'base64'
      response.cookie 'triphash', triphash, { signed: true, httpOnly: true }
    else
      triphash = ''
      response.clearCookie 'triphash'
    ping_user request.body.nickname, triphash
    response.redirect 303, '/'
  else
    route_get request, response

exports.defines =
  { 'verify nickname': verify_nickname
  , 'flush users': flush_users
  , 'list users': list_users
  }

exports.addroutes = (router) ->
  router.get '/nickname'
           , route_get

  router.post '/nickname'
           , route_post
