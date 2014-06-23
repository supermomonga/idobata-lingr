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

    else
      msg.send 'Sorry, you have no authority to do that.'

  robot.hear /([\s\S]+)/, (msg) ->
    unless msg.message.data
      msg.message.data = { room_id: "1" }
    idobata_room_id =  msg.message.data.room_id
    idobata_rooms = if robot.brain.get('idobata') then robot.brain.get('idobata') else {}

    idobata_last_speakers = if robot.brain.get('idobata-last-speakers') then robot.brain.get('idobata-last-speakers') else {}
    idobata_last_speaker = if idobata_last_speakers[idobata_room_id] then idobata_last_speakers[idobata_room_id] else ''
    idobata_last_speakers[idobata_room_id] = msg.message.user.id
    robot.brain.set 'idobata-last-speakers', idobata_last_speakers

    lingr_last_speakers = if robot.brain.get('lingr-last-speakers') then robot.brain.get('lingr-last-speakers') else {}
    if idobata_rooms[idobata_room_id]
      lingr_last_speakers[idobata_rooms[idobata_room_id]] = ''
      robot.brain.set 'lingr-last-speakers', lingr_last_speakers

    bot_id = process.env.LINGR_BOT_ID
    bot_secret = process.env.LINGR_BOT_SECRET
    bot_verifier = Crypto.createHash('sha1').update(bot_id + bot_secret).digest('hex')
    text = if idobata_last_speaker == msg.message.user.id then '' else "<" + msg.message.user.name + ">\n"
    text += msg.match[1]
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
        console.log "Posted to lingr"

  robot.router.post "/idobata/say", (req, res) ->
    message = req.body.events[0].message
    lingr_room_id = message.room
    speaker_id = message.speaker_id
    name = message.nickname
    text = message.text
    icon_url = message.icon_url

    # Detect room
    lingr_rooms = if robot.brain.get('lingr') then robot.brain.get('lingr') else {}

    lingr_last_speakers = if robot.brain.get('lingr-last-speakers') then robot.brain.get('lingr-last-speakers') else {}
    lingr_last_speaker = if lingr_last_speakers[lingr_room_id] then lingr_last_speakers[lingr_room_id] else ''
    lingr_last_speakers[lingr_room_id] = speaker_id
    robot.brain.set 'lingr-last-speakers', lingr_last_speakers

    idobata_last_speakers = if robot.brain.get('idobata-last-speakers') then robot.brain.get('idobata-last-speakers') else {}
    if lingr_rooms[lingr_room_id]
      idobata_last_speakers[lingr_rooms[lingr_room_id]] = ''
      robot.brain.set 'idobata-last-speakers', idobata_last_speakers

    res_body = if lingr_last_speaker == speaker_id then '' else "<" + name + ">\n"
    res_body += text


    if lingr_rooms[lingr_room_id]
      robot.messageRoom lingr_rooms[lingr_room_id], res_body
    res.end ''
