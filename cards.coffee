#
# Module dependencies
#

nedb = require 'nedb'
async = require 'async'

db = { cards: new nedb()
     }

db.cards.ensureIndex { fieldName: field, unique: field == 'title' } for field in ['title', 'faction']

do ->
  factions = require './factions.json'
  for faction in factions then do (faction) ->
    cards = require faction.filename
    for card in cards then do (faction, card) ->
      card.fluff = '' if !card.fluff?
      card.count = 1 if !card.count?
      card.type = 'Action' if !card.type?
      card.faction = faction.faction
      card.power = 6 - card.count if card.type == 'Minion' && !card.power?
      db.cards.insert card, (err, newDoc) ->
        console.log err if err?
        console.log newDoc._id, newDoc.title

db.cards.find {}, (err, docs) ->
  console.log err if err?
  console.log docs
