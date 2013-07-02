#
# Module dependencies
#

nedb = require 'nedb'
async = require 'async'

db = { cards: new nedb()
     }

async.auto {
  cards_indexes: (next) ->
    addIndex = (field, next) ->
      db.cards.ensureIndex { fieldName: field, unique: field == 'title' }, next
    async.each ['title', 'faction'], addIndex, next
, cards_factions: (next) ->
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
}, (err) ->
  db.cards.find {}, (err, results) ->
    console.log results
