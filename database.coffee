#
# Module dependencies
#

fs = require 'fs'
path = require 'path'
nedb = require 'nedb'
async = require 'async'

GLOBAL.db =
  cards: new nedb()
  factions: []

async.auto
  cards_indexes: (next) ->
    console.log 'Adding indexes...'
    addIndex = (field, next) ->
      GLOBAL.db.cards.ensureIndex
        fieldName: field
        unique: field is 'title'
       ,
        next
    async.each ['title', 'faction'], addIndex, next

  cards_factions: (next) ->
    console.log   'Loading factions...'
    factions = (path.join './factions', file for file in fs.readdirSync './factions')
    factions = (file for file in factions when fs.statSync(file).isFile())
    factions = (path.basename file, path.extname file for file in factions)
    loadFaction = (faction, next) ->
      data = require "./factions/#{faction}"
      GLOBAL.db.factions.push data.faction
      console.log "                ...#{data.faction}"
      loadCard = (card, next) ->
        card.fluff = '' unless card.fluff?
        card.count = 1 unless card.count?
        card.type = 'Action' unless card.type?
        card.power = 6 - card.count unless card.power? or card.type isnt 'Minion'
        card.faction = data.faction
        GLOBAL.db.cards.insert card, next
      async.each data.cards, loadCard, next
    async.each factions, loadFaction, next
