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

@timeout = 60 * 60 * 1000

parseuser = (doc) ->
  i = doc.user.indexOf ','
  user = { nickname: doc.user.substring(i + 1)
         , triphash: doc.user.substring(0, i - 1)
         }
  return user

flush_users = (request, response, next) ->
  recentlyseen.remove { lastseen: { $lt: (Date.now() - @timeout) } }, (err, removed) ->
    request.admin.purged.users = removed
    next()

list_users = (request, response, next) ->
  recentlyseen.find { lastseen: { $gte: (Date.now() - @timeout) } }, (err, docs) ->
    request.users = (parseuser doc for doc in docs)
    next()

verify_nickname = (request, response, next) ->
  if request.signedCookies.nickname?
    request.nickname = request.signedCookies.nickname
    request.triphash = request.signedCookies.triphash ? ''
    recentlyseen.update { user: "#{request.triphash},#{request.nickname}" },
                        { $set: { lastseen: Date.now() } },
                        { upsert: true }
  else
    response.redirect '/nickname'
  next()

route_get = (request, response) ->
  response.render 'nickname', { title: 'Express' }

route_post = (request, response) ->
  console.log request.body
  if request.body.nickname? isnt ''
    console.log "Nickname: #{request.body.nickname}"
    response.cookie 'nickname', request.body.nickname, { signed: true, httpOnly: true }
    if request.body.tripcode? isnt ''
      hmac = require('crypto').createHmac 'sha384', '3a846127-1c5d-4622-8156-ed2ea713a68d'
      hmac.update 'fdef7e25-d8d8-4fe4-b9a5-909ffea28d31'
      hmac.update request.body.nickname
      hmac.update '156a3282-8589-4923-a177-f9b039d9ae2b'
      hmac.update request.body.tripcode
      hmac.update 'cee1e7c3-bd88-422c-abd6-23ea04ddcb21'
      triphash = hmac.digest('base64').replace(/\+/g, '.').replace(/\//g, '_')
      response.cookie 'triphash', triphash, { signed: true, httpOnly: true }
      console.log "Triphash: #{triphash}"
    else
      console.log 'Triphash: []'
      response.clearCookie 'triphash'
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
