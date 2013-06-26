#
# GET home page.
#

exports.index = (request, response) ->
  console.log 'Index'
  response.render 'index', { title: 'Express', nickname: request.signedCookies.nickname }
