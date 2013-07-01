#
# Module dependencies
#

nedb = require 'nedb'
next = require 'nextflow'

db = { cards: new nedb('cards.db')
     }

next flow =
  error: (err) ->
    console.log err
  1: ->
    db.cards = new nedb()
    @next()
  1000: ->
    db.cards.insert  { title: 'Crop Circles'
                     , type: 'Action'
                     , faction: 'Aliens'
                     , count: 2
                     }, @next
  1001: ->
    db.cards.insert  { title: 'Disintigrate'
                     , type: 'Action'
                     , faction: 'Aliens'
                     , count: 1
                     }, @next
  9900: ->
    db.cards.ensureIndex { fieldName: 'title'
                         , unique: true
                         }, @next
  9901: ->
    db.cards.ensureIndex { fieldName: 'faction'
                         , sparse: true
                         }, @next
  9999: ->
    console.log db
    db.cards.find {}, (err, docs) ->
      console.log docs
