async = require 'async'
zombie = require 'zombie'

async.auto
  browsers: (next) ->
    console.log "Creating browser instances..."
    create = (item, next) ->
      console.log "                          ...\##{item}..."
      browser = new zombie()
      browser.visit 'http://localhost:5000/nickname', ->
        browser
          .fill('nickname', "Browser #{item}")
          .fill('tripcode', 'WolfWings'[item..])
          .pressButton('Save', ->
            next null, browser
          )
    async.map [0..9], create, next

  create_game: [ 'browsers', (next, results) ->
    console.log 'Creating game w/ Browser #0...'
    browser = results.browsers[0]
    browser.visit 'http://localhost:5000/games', ->
#      console.log browser.html 'body'
      next null, browser
  ]

, (err, results) ->
  console.log err if err?
  console.log "Testing completed."
#  console.log results.create_game
#  for browser in results.browsers
#    for cookie in browser.cookies when "#{cookie}".search(/nickname/) isnt -1
#      "#{cookie}".replace /nickname=s%3A([^.]+)/, (match) ->
#        console.log decodeURIComponent match[13..]
