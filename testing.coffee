async = require 'async'
zombie = require 'zombie'

baseURL = 'http://dev.smashup.wolfwings.us'
baseURL = 'http://localhost'

async.auto
  browsers: (next) ->
    console.log "Creating browser instances..."
    create = (item, next) ->
      console.log "                          ...\##{item}..."
      browser = new zombie()
      browser.visit "#{baseURL}/nickname", ->
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
    browser.visit "#{baseURL}/games", ->
      browser
        .fill('gamename', "Test Game")
        .pressButton('Create', ->
          next null, browser
        )
  ]

, (err, results) ->
  console.log err if err?
  console.log "Testing completed."
