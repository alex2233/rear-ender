#
# Module dependencies
#

exports.loader = (callback) ->
  nedb = require 'nedb'
  async = require 'async'

  db = { cards: new nedb()
       , factions: []
       }

  async.auto {
    cards_indexes: (next) ->
      console.log 'Adding indexes...'
      addIndex = (field, next) ->
        db.cards.ensureIndex { fieldName: field, unique: field is 'title' }, next
      async.each ['title', 'faction'], addIndex, next
  , cards_factions: (next) ->
      console.log   'Loading factions...'
      factions = require './factions.json'
      loadFaction = (faction, next) ->
        db.factions.push faction.faction
        console.log "                ...#{faction.faction}"
        loadCard = (card, next) ->
          card.fluff = '' unless card.fluff?
          card.count = 1 unless card.count?
          card.type = 'Action' unless card.type?
          card.power = 6 - card.count unless card.power? or card.type isnt 'Minion'
          card.faction = faction.faction
          db.cards.insert card, next
        cards = require faction.filename
        async.each cards, loadCard, next
      async.each factions, loadFaction, next
  }, (err) ->
    callback err, db
