#
# Module dependencies
#

nedb = require 'nedb'

db = { cards: new nedb()
     }

factions = require './factions.json'
for faction in factions then do (faction) ->
  cards = require faction.filename
  for card in cards then do (faction, card) ->
    card.faction = faction.faction
    db.cards.insert card

db.cards.ensureIndex { fieldName: field } for field in ['title', 'faction']

console.log db.cards
