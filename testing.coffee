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
    console.log 'Creating game w/ Browser #9...'
    browser = results.browsers[9]
    browser.visit "#{baseURL}/games/create", ->
      console.log browser.html()
      results.browsers[9] = browser
      next null, null
  ]

  join_game: [ 'create_game', (next, results) ->
    console.log 'Joining game...'
    join = (item, next) ->
      console.log "            ...browser \##{item}..."
      browser = results.browsers[item]
      browser.visit "#{baseURL}/games", ->
        console.log browser.html '#games'
        results.browsers[item] = browser
        next null, null
    async.map [0..8], join, next
  ]

, (err, results) ->
  console.log err if err?
  console.log "Testing completed."
