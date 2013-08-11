#
# NickName handling
#

nedb = require 'nedb'

recentlyseen = new nedb()
recentlyseen.ensureIndex { fieldName: 'user', unique: true }

# 60 minutes = 1 hour
# 60 seconds = 1 minute
# 1000 milliseconds = 1 second
# 1 hour in milliseconds

timeout = 60 * 60 * 1000

parseuser = (doc) ->
  i = doc.user.indexOf ','
  user = { nickname: doc.user.substring(i + 1)
         , triphash: doc.user.substring(0, i - 1)
         }
  return user

flush_users = (request, response, next) ->
  recentlyseen.remove { lastseen: { $lt: (Date.now() - (timeout * 2)) } }, (err, removed) ->
    request.admin.purged.users = removed
    next()

list_users = (request, response, next) ->
  recentlyseen.find { lastseen: { $gte: (Date.now() - timeout) } }, (err, docs) ->
    request.users = (parseuser doc for doc in docs)
    next()

ping_user = (nickname, triphash) ->
  console.log "Recently saw #{nickname},#{triphash}..."
  if triphash isnt ''
    hmac = require('crypto').createHmac 'sha384', GLOBAL.config.uuids.hmacsalt
    hmac.update GLOBAL.config.uuids.hashiv
    hmac.update nickname
    hmac.update GLOBAL.config.uuids.hashsv
    hmac.update triphash
    hmac.update GLOBAL.config.uuids.hashtv
    tripcode = hmac.digest('base64')[1..8]
  else
    tripcode = ''

  recentlyseen.update { user: "#{tripcode},#{nickname}" },
                      { $set: { lastseen: Date.now() } },
                      { upsert: true }

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
