#
# User list
#

list_users = (request, response) ->
  response.render 'users', { title: 'User List - ', users: request.users ? {} }

info_user = (request, response) ->
  response.render 'users_info', { title: 'User Details - ', users: request.users ? {} }

exports.addroutes = (router) ->
  router.get '/users'
           , 'verify nickname'
           , 'list users'
           , list_users
