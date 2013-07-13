#
# Module dependencies
#

dispatchington = require 'dispatchington'

database = require './database'
express = require 'express'
jade = require 'jade'
http = require 'http'
path = require 'path'

router = dispatchington()
app = express()

# all environments
app.set 'port', process.env.PORT || 5000
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'
app.set 'view options', { pretty: true }
app.use router.implementedMethods
app.use express.favicon()
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser '45ece46e-a656-49ee-8fc0-659f54e012d5'
app.use express.session()
app.use router.dispatcher
app.use require('stylus').middleware __dirname + '/public'
app.use express.static path.join __dirname, 'public'

# development only
app.use(express.errorHandler()) if (app.get 'env' == 'development')

db = {}
(require './database').loader((err, res) ->
  db = res
)

http.createServer(app).listen app.get('port'), () ->
  console.log 'Express server listening on port ' + app.get('port')

do ->
  model = require './logic/nickname'
  router.define 'verify nickname', model.verify
  router.define 'list users', model.list
  router.get '/nickname', model.get
  router.post '/nickname', model.post

do ->
  model = require './logic/index'
  router.get '/',
    'verify nickname',
    model.index
