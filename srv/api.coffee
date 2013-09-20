crawler = require("./crawl")

module.exports = (app) ->

  app.get "/", (req, res) ->
    res.send("Hello Dave.")

  app.get "/crawl/deep", (req, res) ->
    crawler.crawl req.query, (status, result) ->
      res.status(status).send(result.render())