#
# GET home page.
#

index = (request, response) ->
  console.log 'Index'
  response.render 'index', { title: 'Express', nickname: request.signedCookies.nickname }

exports.addroutes = (router) ->
  router.get '/'
           , 'verify nickname'
           , index

