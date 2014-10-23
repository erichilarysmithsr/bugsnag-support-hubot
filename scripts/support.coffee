require "sugar"
# Any time a NEW person (aka a person Hubot hasn't responded to) enters
# the room outside of 10am-6pm PST and says something, Hubot should respond

module.exports = (robot) ->
  regex = /.*/m

  robot.hear regex, (msg) ->
    currentTime = new Date().utc(true)
    startOfBusinessDay = Date.utc.past("5pm")
    endOfBusinessDay = Date.utc.past("5pm").addHours(8)
    withinBusinessHours = currentTime.isBetween(startOfBusinessDay, endOfBusinessDay)

    if msg.message.room == "bugsnag_support" && !withinBusinessHours && !msg.message.user.jid?
      currentUser = robot.brain.userForId(msg.message.user.id)

      if !currentUser.lockSupport or new Date(currentUser.lockSupport).isBefore("1 hour ago")
        currentUser.lockSupport = currentTime
        mentionName = msg.message.user.mention_name
        userName = msg.message.user.name

        name = if mentionName isnt undefined then "@" + mentionName else userName

        msg.send "Hey #{name}! Thanks for stopping by. Unfortunately, it looks like it's outside of business hours in San Francisco, so a human may not respond right now."

        setTimeout (->
          msg.send "Feel free to send an e-mail with your questions to support@bugsnag.com in the mean time, or come back from 10am-7pm PST."
        ), 100

        setTimeout (->
          msg.send "I'd also recommend checking out our docs page, we may have already answered your question: https://www.bugsnag.com/docs/"
        ), 100
