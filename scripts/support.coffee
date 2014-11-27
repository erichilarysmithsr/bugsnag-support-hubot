require "sugar"
# Any time a NEW person (aka a person Hubot hasn't responded to that isn't
# an employee) enters the room outside of 10am-7pm PST and says something,
# Hubot should respond with an OOO response

module.exports = (robot) ->
  regex = /.*/m

  robot.hear regex, (msg) ->
    currentTime = new Date().utc(true)
    startOfBusinessDay = Date.utc.past("6pm")
    endOfBusinessDay = Date.utc.past("6pm").addHours(9)
    withinBusinessHours = currentTime.isBetween(startOfBusinessDay, endOfBusinessDay)

    holidayDates = ["11/27/2014", "11/28/2014", "12/25/2014", "12/26/2014",
                    "01/01/2015", "02/16/2015", "05/25/2015", "07/03/2015",
                    "09/07/2015", "11/11/2015", "11/26/2015", "11/27/2015",
                    "12/24/2015", "12/25/2015"]
    isHoliday = ->
      holidayDates.some (day) ->
        Date.create(day).isToday()

    isGuest = !msg.message.user.jid?
    isSupportRoom = msg.message.room == "bugsnag_support"
    outOfOffice = (!withinBusinessHours || currentTime.isWeekend() || isHoliday())

    if isSupportRoom && outOfOffice && isGuest
      currentUser = robot.brain.userForId(msg.message.user.id)

      if !currentUser.lockSupport or new Date(currentUser.lockSupport).isBefore("1 hour ago")
        currentUser.lockSupport = currentTime
        mentionName = msg.message.user.mention_name
        userName = msg.message.user.name

        name = if mentionName isnt undefined then "@" + mentionName else userName
        supportMessage = "Hey #{name}! Thanks for stopping by. Unfortunately, it looks like it's outside of business hours in San Francisco, so a human may not respond right now.\nFeel free to send an e-mail with your questions to support@bugsnag.com in the mean time, or come back from 10am-7pm PST.\nI'd also recommend checking out our docs page, we may have already answered your question: https://www.bugsnag.com/docs/"

        setTimeout (->
          msg.send supportMessage
        ), 2000
