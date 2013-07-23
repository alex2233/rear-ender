This module defined the *nickname handling* for the webapp. It uses a system
sharing more with the mentality of 'image board' systems than traditional
ones in that there are no server-side credentials stored or demanded.

We rely on an internal 'database' of recently seen users paired with how
recently we saw them, with the 'user' field being a reversable amalgamation
of their nickname and tripcode to define a unique person hitting the site.

	nedb = require 'nedb'
	recentlyseen = new nedb()
	recentlyseen.ensureIndex { fieldName: 'user', unique: true }

The timeout defined here is 1 hour in milliseconds: 60 * 60 * 1000

	@timeout = 60 * 60 * 1000

Utility Functions
=================

This function reverses the nickname/tripcode amalgamation in a
*list comprehension* compatible way.

	parseuser = (doc) ->
	  i = doc.user.indexOf ','
	  user = { nickname: doc.user.substring(i + 1)
	         , triphash: doc.user.substring(0, i - 1)
	         }
	  return user

Middleware
==========

Callbacks
---------

Callback to allow flushing the list of *recently seen* users from any
arbitrary route in the site.

Also populates the `request.admin.purged.users` with an integer count
of the number of recently-seen user records purged.

	flush_users = (request, response, next) ->
	  recentlyseen.remove { lastseen: { $lt: (Date.now() - @timeout) } }, (err, removed) ->
	    request.admin.purged.users = removed
	    next()

Callback to populate the `request.users` element with an array of users
that have visited the site inside the `@timeout` timespan.

The array is populated with objects with the properties `nickname` and
`triphash` set appropriately for easy display from a jade template.

	list_users = (request, response, next) ->
	  recentlyseen.find { lastseen: { $gte: (Date.now() - @timeout) } }, (err, docs) ->
	    request.users = (parseuser doc for doc in docs)
	    next()

Callback that is the closest we have to an *authentication* point in the
codebase. If they have a `nickname` cookie, let them continue on. If not
then redirect them to the `/nickname` URL to force them to pick one.

This is also the sole point that updates the recently-seen database set,
so it ends up being a hot-path for that database.

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

Exports
-------

	exports.defines =
	  { 'verify nickname': verify_nickname
	  , 'flush users': flush_users
	  , 'list users': list_users
	  }

Routes
======

Callbacks
---------

If you **GET** the `/nickname` route, just hand back the *enter a nickname*
page, nothing more.

	route_get = (request, response) ->
	  response.render 'nickname', { title: 'Express' }

If you **POST** the `/nickname` route, then we have to HMAC some values to
generate your internal secure triphash if you entered a tripcode, and setup
your cookies appropriately based on all of that.

	route_post = (request, response) ->
	  console.log request.body
	  if request.body.nickname? isnt ''
	    console.log "Nickname: #{request.body.nickname}"
	    response.cookie 'nickname', request.body.nickname, { signed: true, httpOnly: true }
	    if request.body.tripcode? isnt ''
	      hmac = require('crypto').createHmac 'sha384', GLOBAL.config.uuids.hmacsalt
	      hmac.update GLOBAL.config.uuids.hashiv
	      hmac.update request.body.nickname
	      hmac.update GLOBAL.config.uuids.hashsv
	      hmac.update request.body.tripcode
	      hmac.update GLOBAL.config.uuids.hashtv
	      triphash = hmac.digest('base64')
	      response.cookie 'triphash', triphash, { signed: true, httpOnly: true }
	      console.log "Triphash: #{triphash}"
	    else
	      console.log 'Triphash: []'
	      response.clearCookie 'triphash'
	    response.redirect 303, '/'
	  else
	    route_get request, response

Exports
-------

	exports.addroutes = (router) ->
	  router.get '/nickname'
	           , route_get
	  router.post '/nickname'
	           , route_post
