#
# GLOBAL.config
#

require './config'

#
# Module dependencies
#

dispatchington = require 'dispatchington'
database = require './database'
express = require 'express'
jade = require 'jade'
http = require 'http'
path = require 'path'
fs = require 'fs'

router = dispatchington()
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

logicfiles = (path.join './logic', file for file in fs.readdirSync './logic')
logicfiles = (file for file in logicfiles when fs.statSync(file).isFile())
logicfiles = (path.basename file, path.extname file for file in logicfiles)

#
# Load definitions from logic files first
#
console.log 'Defining middleware...'
for file in logicfiles
  do ->
    model = require "./logic/#{file}"
    console.log "                   ...#{file}..."
    for item, callback of model.defines
      console.log "                      ...#{item}"
      router.define item, callback

#
# Load routes from logic files second
#
console.log 'Adding routes from...'
for file in logicfiles
  do ->
    console.log "                  ...#{file}"
    model = require "./logic/#{file}"
    model.addroutes(router)
