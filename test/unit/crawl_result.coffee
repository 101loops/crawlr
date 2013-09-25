webresources = require("../../srv/web_resources")

chai = require("chai")
expect = chai.expect

describe "Web Resource", ->

  it "should merge", ->
    wr = webresources()
    expect(wr.length()).to.equal(0)

    wr.add
      kind: "link"
      url: "http://test.com"
    wr.add
      kind: "image"
      url: "http://test.com/logo.png"
    expect(wr.length()).to.equal(2)

    wr2 = webresources()
    wr2.add
      kind: "link"
      url: "http://www.test.com/about"
    wr2.add
      kind: "image"
      url: "http://www.test.com/logo.png"
    expect(wr2.length()).to.equal(2)

    wm = wr.merge(wr2)
    expect(wm.length()).to.equal(3)
