exports.faction = 'Dinosaurs'

exports.cards =
[
    title:      'Augmentation'
    count:      2
    fluff:      "One minion gains +4 power until the end of your turn."
  ,
    title:      'Howl'
    count:      2
    fluff:      "Each of your minions gains +1 power until the end of your turn."
  ,
    title:      'Rampage'
    fluff:      "Reduce the breakpoint of a base by the power of one of your minions on that base until the end of the turn."
  ,
    title:      'Survival of the Fittest'
    fluff:      "Destroy the lowest-power minion (you choose in case of a tie) on each base with a higher-power minion."
  ,
    title:      'Tooth and Claw... and Guns'
    fluff:      "Play on a minion. Ongoing: If an ability would affect this minion, destroy this card and the ability does not affect this minion."
  ,
    title:      'Wildlife Preserve'
    fluff:      "Play on a base. Ongoing: Your minions here are not affected by other players' actions."
  ,
    title:      'Upgrade'
    fluff:      "Play on a minion. Ongoing: This minion has +2 power."
  ,
    title:      'Natural Selection'
    fluff:      "Choose one of your minions on a base. Destroy a minion there with less power than yours."
  ,
    title:      'War Raptor'
    type:       'Minion'
    count:      4
    fluff:      "Ongoing: Gains +1 power for each War Raptor on this base (including this one)."
  ,
    title:      'Armor Stego'
    type:       'Minion'
    count:      3
    fluff:      "Ongoing: Has +2 power during other players' turns."
  ,
    title:      'Lasertops'
    type:       'Minion'
    count:      2
    fluff:      "Destroy a minion of power 2 or less on this base."
  ,
    title:      'King Rex'
    type:       'Minion'
    power:      7
  ,
    title:      'Jungle Oasis'
    type:       'Base'
    breakpoint: 12
    value:      [2, 0, 0]
  ,
    title:      'Tar Pits'
    type:       'Base'
    breakpoint: 16
    value:      [4, 3, 2]
    fluff:      "After each time a minion is destroyed here, place it at the botom of its owner's deck."
]
