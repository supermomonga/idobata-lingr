# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#   hubot die - End hubot process

Request = require "request"
Crypto = require 'crypto'
Util = require 'util'

module.exports = (robot) ->
  robot.hear /(.+)$/i, (msg) ->
    console.log msg.message
    console.log msg.envelope
    # msg.send process.env.LINGR_BOT_SECRET
    msg.send msg.match[1]
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

