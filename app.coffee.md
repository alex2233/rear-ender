#
# GLOBAL.config
#

require './config'

#
# Module dependencies
#

router = require('dispatchington')()
async = require 'async'
path = require 'path'
fs = require 'fs'
express = require 'express'
http = require 'http'
jade = require 'jade'

async.auto
  load_database: (next, results) ->
    require './database'
    next null, results

  router_setup: (next, results) ->
    app = express()

    # all environments
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
    # app.use express.session()
    app.use router.dispatcher
    app.use require('stylus').middleware __dirname + '/public'
    app.use express.static path.join __dirname, 'public'

    # development only
    app.use(express.errorHandler()) if (app.get 'env' is 'development')

    http.createServer(app).listen app.get('port'), () ->
      console.log 'Express server listening on port ' + app.get('port')

    next null, results

  logic_list_files: (next, results) ->
    results.logicfiles = (
      path.basename file, path.extname file \
      for file in fs.readdirSync './logic' \
      when fs.statSync(path.join './logic', file).isFile()
    )
    next null, results

  logic_load_middleware: ['logic_list_files', (next, results) ->
    console.log 'Defining middleware...'
    for file in results.logicfiles
      console.log "                   ...#{file}..."
      for item, callback of require("./logic/#{file}").defines
        console.log "                      ...#{item}"
        router.define item, callback
    next null, results
  ]

  logic_load_routes: ['logic_list_files', 'logic_load_middleware', (next, results) ->
    console.log 'Adding routes from...'
    for file in results.logicfiles
      console.log "                  ...#{file}"
      require("./logic/#{file}").addroutes(router)
    next null, results
  ]
