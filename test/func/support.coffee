express = require("express")
setup = require("../../setup")
http = require("http")

app = express()

PORT = 9876
HOST = "localhost"
SECRET = "secret"

class TestServer

  constructor: ->
    setup(app, SECRET)

  start: ->
    app.listen(PORT, HOST)

  stop: ->
    #app.close()


module.exports =
  createServer: ->
    new TestServer

  url: (path) ->
    "http://" + HOST + ":" + PORT + path

  authQry: ->
    "auth=" + SECRET