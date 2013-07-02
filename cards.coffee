#
# Module dependencies
#

nedb = require 'nedb'
async = require 'async'

db = { cards: new nedb()
     }

async.parallel(
  [ (next) ->
    addIndex = (field, next) ->
      db.cards.ensureIndex { fieldName: field, unique: field == 'title' }, next
    async.each ['title', 'faction'], addIndex, next
  , (next) ->
    factions = require './factions.json'
    loadFaction = (faction, next) ->
      loadCard = (card, next) ->
        card.fluff = '' if !card.fluff?
        card.count = 1 if !card.count?
        card.type = 'Action' if !card.type?
        card.power = 6 - card.count if card.type == 'Minion' && !card.power?
        card.faction = faction.faction
        db.cards.insert card, next
      cards = require faction.filename
      async.each cards, loadCard, next
    async.each factions, loadFaction, next
  ], (err, results) ->
    console.log err if err?
    console.log db.cards
)
