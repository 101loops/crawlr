express = require("express")

module.exports = (app, SECRET) ->

  app.configure ->
    #app.use express.logger()

    CORS = (req, res, next) ->
      res.header "Access-Control-Allow-Origin", "*"
      res.header "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE"
      next()
    app.use CORS

    AUTH = (req, res, next) ->
      auth = req.header("Authorization") || req.query.auth || ""
      if auth.indexOf(SECRET) == -1
        res.status(401).send("No Trespassing")
      else
        next()
    app.use AUTH

    app.use app.router

  require("./srv/api")(app)