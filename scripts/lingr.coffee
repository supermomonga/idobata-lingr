# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#   hubot die - End hubot process
#   hubot assign gateway with lingr:<lingr_room_id>

Request = require "request"
Crypto = require 'crypto'
Util = require 'util'

module.exports = (robot) ->
  robot.hear /gateway status$/i, (msg) ->
    unless msg.message.data
      msg.message.data = { room_id: "1" }
    idobata_room_id = msg.message.data.room_id
    idobata_rooms =  robot.brain.get 'idobata'
    if idobata_rooms and idobata_rooms[idobata_room_id]
      msg.send "room " + idobata_room_id + " is connected with `" + idobata_rooms[idobata_room_id] + "`"
    else
      msg.send "room " + idobata_room_id + " isn't connected with any room yet."



  robot.hear /assign gateway with ([^\s]+)$/i, (msg) ->
    if robot.auth.hasRole(msg.message.user,'admin')
      unless msg.message.data
        msg.message.data = { room_id: "1" }
      idobata_room_id =  msg.message.data.room_id
      lingr_room_id =  msg.match[1]

      idobata_rooms = if robot.brain.get('idobata') then robot.brain.get('idobata') else {}
      lingr_rooms = if robot.brain.get('lingr') then robot.brain.get('lingr') else {}

      idobata_rooms[idobata_room_id] = lingr_room_id
      lingr_rooms[lingr_room_id] = idobata_room_id

      robot.brain.set 'idobata', idobata_rooms
      robot.brain.set 'lingr', lingr_rooms
      msg.send "Done.\nnow room `" + robot.brain.get('lingr')[lingr_room_id] + "` is connected with `" + robot.brain.get('idobata')[idobata_room_id] + "`"
      # msg.send "Done.\nnow room `" + idobata_room_id + "` is connected with `" + lingr_room_id + "`"

    else
      msg.send 'Sorry, you have no authority to do that.'

  robot.hear /list gateway$/i, (msg) ->
      console.log "hi"
      msg.send "hi"

  robot.hear /(.+)$/i, (msg) ->
    unless msg.message.data
      msg.message.data = { room_id: "1" }
    idobata_room_id =  msg.message.data.room_id
    idobata_rooms = if robot.brain.get('idobata') then robot.brain.get('idobata') else {}
    bot_id = process.env.LINGR_BOT_ID
    bot_secret = process.env.LINGR_BOT_SECRET
    bot_verifier = Crypto.createHash('sha1').update(bot_id + bot_secret).digest('hex')
    text = msg.message.user.name + ": " + msg.match[1]
    if idobata_rooms[idobata_room_id]
      query =
        room: idobata_rooms[idobata_room_id]
        bot: bot_id
        text: text
        bot_verifier: bot_verifier
    robot.http('http://lingr.com')
      .path('/api/room/say')
      .query(query)
      .get() (err, res, body) ->
        console.log body
    # options = {
    #   uri: 'https://.herokuapp.com/'
    # }
    # Request.post

  # robot.respond /ADAPTER$/i, (msg) ->
  #   msg.send robot.adapterName
  #
  # robot.respond /ECHO (.*)$/i, (msg) ->
  #   msg.send msg.match[1]
  #
  # robot.respond /TIME$/i, (msg) ->
  #   msg.send "Server time is: #{new Date()}"
  #
  # robot.respond /DIE$/i, (msg) ->
  #   msg.send "Goodbye, cruel world."
  #   process.exit 0

