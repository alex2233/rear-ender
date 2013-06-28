#
# Module dependencies
#

nedb = require 'nedb'
db = { cards: new nedb('cards.db')
     }
db.cards.insert	{ title: 'Crop Circles'
		, type: 'Action'
		, faction: 'Aliens'
		, count: 2
		}

db.cards.ensureIndex { fieldName: 'faction', sparse: true }, (err) ->
  console.log err if err?

console.log db
