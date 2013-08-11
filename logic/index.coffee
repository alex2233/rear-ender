#
# GET home page.
#

index = (request, response) ->
  response.render 'index', { title: '', nickname: request.signedCookies.nickname }

exports.addroutes = (router) ->
  router.get '/'
           , 'verify nickname'
           , index

