require "sugar"
# Any time a NEW person (aka a person Hubot hasn't responded to) enters
# the room outside of 10am-6pm PST and says something, Hubot should respond

module.exports = (robot) ->
  regex = /.*/m

  robot.hear regex, (msg) ->
    currentTime = new Date().utc(true)
    withinBusinessHours = currentTime.isBetween("5pm", "1am")

    if msg.message.room == "bugsnag_support" && !withinBusinessHours
      currentUser = robot.brain.userForId(msg.message.user.id)


      if !currentUser.lockSupport or currentUser.lockSupport.isBefore("1 hour ago")
        currentUser.lockSupport = currentTime

        msg.send "Hey @#{msg.message.user.mention_name}! Thanks for stopping by. Unfortunately, it looks like it's outside of business hours in San Francisco, so a human may not respond right now."
        msg.send "Feel free to send an e-mail with your questions to support@bugsnag.com in the mean time, or come back from 10am-6pm PST."
        msg.send "I'd also recommend checking out our docs page, we may have already answered your question: https://www.bugsnag.com/docs/"
