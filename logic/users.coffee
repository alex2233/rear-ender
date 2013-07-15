#
# User list
#

list_users = (request, response) ->
  console.log request.users ? {}
  response.render 'users', { title: 'Express', users: request.users ? {} }

exports.addroutes = (router) ->
  router.get '/users'
           , 'list users'
           , list_users
