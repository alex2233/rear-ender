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
  loadFaction = (faction, next) ->
    loadCard = (card, next) ->
      card.fluff = '' if !card.fluff?
      card.count = 1 if !card.count?
      card.type = 'Action' if !card.type?
      card.power = 6 - card.count if card.type == 'Minion' && !card.power?
      card.faction = faction.faction
      db.cards.insert card, next
    cards = require faction.filename
    async.eachSeries cards, loadCard, next
  async.each factions, loadFaction, (err) ->
    console.log db.cards
