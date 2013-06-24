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
      hmac = require('crypto').createHmac 'sha512', '3a846127-1c5d-4622-8156-ed2ea713a68d'
      hmac.update request.body.nickname
      triphash = '#' + hmac.digest('base64').substring 0, 8
    response.cookie 'tripcode', triphash, { signed: true, httpOnly: true }
    response.redirect 303, '/'

  exports.get request, response
