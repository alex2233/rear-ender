Note that this is more of an 'automated module loader' than a true
event loop or application. It loads the global configuration file,
initializes a fixed database, then proceeds to scan and load every
business-logic module found in dependancy order.

Configuration Settings
======================

      require './config'

Module Depenencies
==================

      router = require('dispatchington')()
      async = require 'async'
      path = require 'path'
      fs = require 'fs'
      express = require 'express'
      http = require 'http'
      jade = require 'jade'

ASync Waterfall-based Loader
============================

By (ab)using async.auto our code ends up more self-organizing when
it comes to loading components in the correct order; by simply
specifying what each step relies on it will be loaded as soon as
all such requirements are met.

Due to CoffeeScript's terse format, the actual call is abruptly brief.

      async.auto

Database
--------

This is the global database of cards, organized into factions and
with various sanity-checks and indexes computed on load.

        load_database: (next, results) ->
          require './database'
          next null, results

Express Router
--------------

We're using a combination of `dispatchington` and the `express`
router, with the `jade` templating engine in this case.

The code below is designed to be deployable to Heroke or other
platforms that define crucial aspects via environmental variables.

        router_setup: (next, results) ->
          app = express()
          app.set 'port', process.env.PORT or 5000
          app.set 'views', __dirname + '/templates'
          app.set 'view engine', 'jade'
          app.set 'view options', { pretty: true }
          app.use router.implementedMethods
          app.use express.favicon()
          app.use express.logger 'dev'
          app.use express.bodyParser()
          app.use express.methodOverride()
          app.use express.cookieParser GLOBAL.config.uuids.cookies
          app.use router.dispatcher
          app.use require('stylus').middleware __dirname + '/public'
          app.use express.static path.join __dirname, 'public'
      
          # development only
          app.use(express.errorHandler()) if (app.get 'env' is 'development')
      
          http.createServer(app).listen app.get('port'), () ->
            console.log 'Express server listening on port ' + app.get('port')
      
          next null, results

Business Logic Scan
-------------------

This step is a preliminary pass to locate and build a list of all
business-logic files that will need to be processed.

        logic_list_files: (next, results) ->
          results.logicfiles = (
            path.basename file, path.extname file \
            for file in fs.readdirSync './logic' \
            when fs.statSync(path.join './logic', file).isFile()
          )
          next null, results

Business Logic Middleware
-------------------------

Each business-logic file has a block defining any filter
callbacks it exposes, all of which are globally registered
in this pass with the `router` used.

        logic_load_middleware: ['logic_list_files', (next, results) ->
          console.log 'Defining middleware...'
          for file in results.logicfiles
            console.log "                   ...#{file}..."
            for item, callback of require("./logic/#{file}").defines
              console.log "                      ...#{item}"
              router.define item, callback
          next null, results
        ]

Business Logic Routes
---------------------

Finally, we pull in the list of routes. Due to the complex nature
this is handled as a callback per business-logic file, which is
only called after all filters from ALL business-logic files
has been loaded so any file can rely on all filters.

        logic_load_routes: ['logic_list_files', 'logic_load_middleware', (next, results) ->
          console.log 'Adding routes from...'
          for file in results.logicfiles
            console.log "                  ...#{file}"
            require("./logic/#{file}").addroutes(router)
          next null, results
        ]
