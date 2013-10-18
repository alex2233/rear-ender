This module handles tripcode-based nicknames, providing
some degree of authentication without requiring explicit
registration or credential storage.

This is based on the 4chan-style `secure tripcodes`
concept, using HMACs and secret salts to intermix
with the combination of user-provided plaintext name
and the tripcode that is mixed in to generate the
unique hash displayed alongside the name.

Module Dependency
================= 
     
      nedb = require 'nedb'

Initialization/Constants
========================

This is the actual list of recently seen (since the `timeout` value)
username/tripcode pairs.

      recentlyseen = new nedb()
      recentlyseen.ensureIndex { fieldName: 'unique', unique: true }

The timeout for values is in milliseconds, so:

 * 1000 milliseconds = 1 second
 * 60 seconds = 1 minute
 * 60 minutes = 1 hour

      
      timeout = 60 * 60 * 1000
      

Core Logic
==========

The following two functions handle flushing old users, and getting
a valid list of recently-seen users for other uses.

      flush_users = (request, response, next) ->
        recentlyseen.remove { lastseen: { $lt: (Date.now() - timeout) } }, (err, removed) ->
          request.admin.purged.users = removed
          next()
      
      list_users = (request, response, next) ->
        recentlyseen.find { lastseen: { $gte: (Date.now() - timeout) } }, (err, docs) ->
          filter = (doc) ->
            nickname: doc.nickname
            tripcode: doc.tripcode
            lastseen: doc.lastseen
          request.users = (filter doc for doc in docs)
          next()

This is the core function which updates an existing user link,
or adds them if they weren't on the list before. It also handles
most of the HMAC encoding to generate the working values used
elsewhere on the site, and caching them so they only have to be
generated once.

      ping_user = (nickname, triphash) ->
        recentlyseen.update
          unique: "#{triphash},#{nickname}"
        ,
          $set:
            lastseen: Date.now()
        ,
          upsert: true
        ,
          (err, numReplaced, upserted) ->
            if upserted
              if triphash is ''
                tripcode = ''
                console.log "First sighting of #{nickname}... (no tripcode)"
              else
                hmac = require('crypto').createHmac 'sha384', GLOBAL.config.uuids.hmacsalt
                hmac.update GLOBAL.config.uuids.hashiv
                hmac.update nickname
                hmac.update GLOBAL.config.uuids.hashsv
                hmac.update triphash
                hmac.update GLOBAL.config.uuids.hashtv
                tripcode = hmac.digest('base64')[1..8]
                console.log "First sighting of #{nickname},#{triphash[1..10]}... (generated tripcode #{tripcode})"
      
              recentlyseen.update
                unique: "#{triphash},#{nickname}"
              ,
                $set:
                  tripcode: tripcode
                  nickname: nickname
            else
              if triphash is ''
                console.log "Return visit from #{nickname}..."
              else
                console.log "Return visit from #{nickname},#{triphash[1..10]}..."

This is the actual public callback for most of this, verifying
someone is on the list as needed, and populating internal data
structures with their internal UID and so-forth for later use.

      verify_nickname = (request, response, next) ->
        if request.signedCookies.nickname?
          request.nickname = request.signedCookies.nickname
          request.triphash = request.signedCookies.triphash ? ''
          ping_user request.nickname, request.triphash
        else
          response.redirect '/nickname'
        next()

On any **GET** request we assume they're wanting to fill in and/or
change their username/tripcode.

      route_get = (request, response) ->
        response.render 'nickname', { title: 'Enter Nickname - ' }

This section verifies they have all the proper fields set in their
HTTP request, and if so populates the keys with appropriate values.

In effect this is the closest we get to a 'login' step.

      route_post = (request, response) ->
        if request.body.nickname? isnt ''
          response.cookie 'nickname', request.body.nickname, { signed: true, httpOnly: true }
          if request.body.tripcode ? false
            hmac = require('crypto').createHmac 'sha384', GLOBAL.config.uuids.hmacsalt
            hmac.update GLOBAL.config.uuids.hashiv
            hmac.update request.body.nickname
            hmac.update GLOBAL.config.uuids.hashsv
            hmac.update request.body.tripcode
            hmac.update GLOBAL.config.uuids.hashtv
            triphash = hmac.digest 'base64'
            response.cookie 'triphash', triphash, { signed: true, httpOnly: true }
          else
            triphash = ''
            response.clearCookie 'triphash'
          ping_user request.body.nickname, triphash
          response.redirect 303, '/'
        else
          route_get request, response

Middleware Exports
==================

      exports.defines =
        { 'verify nickname': verify_nickname
        , 'flush users': flush_users
        , 'list users': list_users
        }

Route Definitions
=================

      exports.addroutes = (router) ->
        router.get '/nickname'
                 , route_get
      
        router.post '/nickname'
                 , route_post
