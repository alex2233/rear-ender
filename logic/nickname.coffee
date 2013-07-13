#
# NickName handling
#

nedb = require 'nedb'

recentlyseen = new nedb()
recentlyseen.ensureIndex { fieldName: 'user', unique: true }

parseuser = (doc) ->
  i = doc.user.indexOf ','
  user = { nickname: doc.user.substring(i + 1)
         , triphash: doc.user.substring(0, i - 1)
         }
  return user

exports.verify = (request, response, next) ->
  if request.signedCookies.nickname?
    request.nickname = request.signedCookies.nickname
    request.triphash = request.signedCookies.triphash ? ''
    recentlyseen.update { user: "#{request.triphash},#{request.nickname}" },
                        { $set: { lastseen: Date.now() } },
                        { upsert: true }
  else
    response.redirect '/nickname'
  next()

exports.list = (request, response, next) ->
  recentlyseen.find { lastseen: { $gte: (Date.now() - 3600000) } }, (err, docs) ->
    request.users = (parseuser doc for doc in docs)
    next()

exports.get = (request, response) ->
  response.render 'nickname', { title: 'Express' }

exports.post = (request, response) ->
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
    exports.get request, response
