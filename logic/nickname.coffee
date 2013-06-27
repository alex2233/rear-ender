#
# NickName handling
#

exports.verify = (request, response, next) ->
  console.log request.signedCookies
  response.redirect '/nickname' unless request.signedCookies.nickname?
  next()

exports.get = (request, response) ->
  response.render 'nickname', { title: 'Express' }

exports.post = (request, response) ->
  console.log request.body

  if request.body.nickname?
    response.cookie 'nickname', request.body.nickname, { signed: true, httpOnly: true }
    triphash = ''
    if request.body.tripcode?
      hmac = require('crypto').createHmac 'sha384', '3a846127-1c5d-4622-8156-ed2ea713a68d'
      hmac.update 'fdef7e25-d8d8-4fe4-b9a5-909ffea28d31'
      hmac.update request.body.nickname
      hmac.update '156a3282-8589-4923-a177-f9b039d9ae2b'
      hmac.update request.body.tripcode
      hmac.update 'cee1e7c3-bd88-422c-abd6-23ea04ddcb21'
      triphash = hmac.digest('base64').replace(/\+/g, '.').replace(/\//g, '_')
    response.cookie 'tripcode', triphash, { signed: true, httpOnly: true }
    response.redirect 303, '/'

  exports.get request, response
