_s = require("underscore.string")
_ = require("lodash")

log = require("./log")

crawlNetworks = (links, opts) ->
  crawlTwitter(links, opts).concat(
    crawlLinkedin(links, opts)
  ).concat(
    crawlFacebook(links, opts)
  ).concat(
    crawlTumblr(links, opts)
  ).concat(
    crawlGooglePlus(links, opts)
  ).concat(
    crawlPinterest(links, opts)
  )

pickNetworkLink = (links, opts) ->
  linkCount = links.length
  if linkCount == 1
    links[0].url
  else if linkCount > 1
    links[0].url # TODO
  else
    undefined

crawlTwitter = (links, opts) ->
  resources = []
  url = opts.twitter ? pickNetworkLink(links.withUrlMatch("twitter.com/"), opts)
  if url
    log("crawling " + url)
    # TODO
  uniqueLinks(resources)

crawlFacebook = (links, opts) ->
  resources = []
  url = opts.facebook ? pickNetworkLink(links.withUrlMatch("facebook.com/"), opts)
  if url
    log("crawling " + url)
    # TODO
  uniqueLinks(resources)

crawlLinkedin = (links, opts) ->
  resources = []
  url = opts.linkedin ? pickNetworkLink(links.withUrlMatch("linkedin.com/"), opts)
  if url
    log("crawling " + url)
    # TODO
  uniqueLinks(resources)

crawlTumblr = (links, opts) ->
  resources = []
  url = opts.tumblr ? pickNetworkLink(links.withUrlMatch("tumblr.com/"), opts)
  if url
    log("crawling " + url)
    # TODO
  uniqueLinks(resources)

crawlGooglePlus = (links, opts) ->
  resources = []
  url = opts.gplus ? pickNetworkLink(links.withUrlMatch("plus.google.com/"), opts)
  if url
    log("crawling " + url)
    # TODO
  uniqueLinks(resources)

crawlPinterest = (links, opts) ->
  resources = []
  url = opts.pinterest ? pickNetworkLink(links.withUrlMatch("pinterest.com/"), opts)
  if url
    log("crawling " + url)
    # TODO
  uniqueLinks(resources)