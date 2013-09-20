chai = require("chai")
request = require("request")
helper = require("./support")

server = null
expect = chai.expect

describe "API", ->

  # ==== SETUP

  before ->
    server = helper.createServer()
    server.start()

  after ->
    server.stop()

  # ==== TESTS

  it "GET / should return 401", (done) ->
    request.get helper.url("/"), (err, resp, body) ->
      expect(resp.statusCode).to.equal(401)
      done()

  it "GET / with SECRET should return 200", (done) ->
    request.get helper.url("/?" + helper.authQry()), (err, resp, body) ->
      expect(resp.statusCode).to.equal(200)
      done()

  it "crawl soundcloud.com", (done) ->
    request.get helper.url("/crawl/deep?root=http://www.soundcloud.com&" + helper.authQry()), (err, resp, body) ->
      expect(resp.statusCode).to.equal(200)
      expect(body).to.be.a("string")

      json = JSON.parse(body)
      expect(json).to.have.property("url")
      expect(json["url"]).to.equal("http://www.soundcloud.com")

      # TODO

      done()

  it "crawl researchgate.net", (done) ->
    request.get helper.url("/crawl/deep?root=http://www.researchgate.net&" + helper.authQry()), (err, resp, body) ->
      expect(resp.statusCode).to.equal(200)
      expect(body).to.be.a("string")

      json = JSON.parse(body)
      expect(json).to.have.property("url")
      expect(json["url"]).to.equal("http://www.researchgate.net")

      # TODO

      done()