zombie = require 'zombie'

browsers = []
for i in [1..10]
  do ->
    slot = i
    browser = new zombie()
    browsers[slot] = browser
    browser.visit 'http://localhost:5000/nickname', ->
      browser
        .fill('nickname', "Browser #{slot}")
        .fill('tripcode', '')
        .pressButton 'Save', ->
          console.log browser.cookies
