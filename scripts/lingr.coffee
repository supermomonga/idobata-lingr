# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#   hubot die - End hubot process
#   hubot assign gateway <idobata_room_id>=<lingr_room_id>

Request = require "request"
Crypto = require 'crypto'
Util = require 'util'

module.exports = (robot) ->
  robot.hear /assign gateway (\d+)=([^\s]+)$/i, (msg) ->
    if robot.auth.hasRole(msg.message.user,'admin')
      idobata_room_id =  msg.match[1]
      lingr_room_id =  msg.match[2]
      unless robot.brain.data.idobata
        robot.brain.data.idobata = []
      unless robot.brain.data.lingr
        robot.brain.data.lingr = []
      robot.brain.data.idobata.idobata_room_id = lingr_room_id
      robot.brain.data.lingr.lingr_room_id = idobata_room_id
      msg.send "Done.\nnow room `" + idobata_room_id + "` is connected with `" + lingr_room_id + "`"

    else
      msg.send 'Sorry, you have no authority to do that.'

  robot.hear /list gateway$/i, (msg) ->
      console.log "hi"
      msg.send "hi"

  robot.hear /(.+)$/i, (msg) ->
    # console.log msg.message
    # console.log msg.envelope
    # msg.send process.env.LINGR_BOT_SECRET
    # msg.send msg.match[1]
    # query =
    #   room: 
    # robot.http('http://lingr.com')
    #   .path('/api/room/say')
    #   .query(query)
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

