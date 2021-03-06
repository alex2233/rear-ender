exports.faction = 'Aliens'

exports.cards =
[
    title:      'Beam Up'
    count:      2
    fluff:      "Return a minion to its owner's hand."
  ,
    title:      'Disintigrate'
    count:      2
    fluff:      "Place a minion of power 3 or less on the bottom of its owner's deck."
  ,
    title:      'Probe'
    fluff:      "Look at another player's hand and choose a minion in it. That player discards that minion."
  ,
    title:      'Crop Circles'
    fluff:      "Choose a base. Return each minion on that base to its owner's hand."
  ,
    title:      'Abduction'
    fluff:      "Return a minion to its owner's hand. Play an extra minion."
  ,
    title:      'Terraforming'
    fluff:      "Search the base deck for a base. Swap it with a base in play (discard all actions attached to it). Shuffle the base deck. You may not play an extra minion on the new base."
  ,
    title:      'Invasion'
    fluff:      "Move a minion to another base."
  ,
    title:      'Jammed Signal'
    fluff:      "Play on a base. Ongoing: All players ignore this base's ability."
  ,
    title:      'Collector'
    type:       'Minion'
    count:      4
    fluff:      "You may return a minion of power 3 or less on this base to its owner's hand."
  ,
    title:      'Scout'
    type:       'Minion'
    count:      3
    fluff:      "Special: After this base is scored, you may place this minion into your hand instead of the discard pile."
  ,
    title:      'Invader'
    type:       'Minion'
    count:      2
    power:      3
    fluff:      "Gain 1 VP."
  ,
    title:      'Supreme Overlord'
    type:       'Minion'
    fluff:      "You may return a minion to its owner's hand."
  ,
    title:      'The Homeworld'
    type:       'Base'
    breakpoint: 23
    value:      [ 4, 2, 1 ]
    fluff:      "After each time a minion is played here, its owner may play an extra minion of power 2 or less."
  ,
    title:      'The Mothership'
    type:       'Base'
    breakpoint: 20
    value:      [ 4, 2, 1 ]
    fluff:      "After this base scores, the winner may return one of his or her minions of power 3 or less from here to his or her hand."
]
