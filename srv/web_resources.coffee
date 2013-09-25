_s = require("underscore.string")
_ = require("lodash")

URL = require("url")
log = require("./log")
webutil = require("./web_util")

linkKeywords = [
  "blog", "developers", "hiring", "job", "career", "about", "contact",
  "press", "imprint", "team", "news", "company"
]

# ==== INTERFACE

class WebResources

  constructor: (array = []) ->
    @resources = array

  add: (res) ->
    @resources.push res

  getList: ->
    @resources

  merge: (source) ->
    new WebResources(
      @resources.concat(source.getList())
    ).unique()

  links: ->
    @filter (res) -> res.kind == "link"

  filter: (fn) ->
    new WebResources(
      _.filter @resources, fn
    )

  withUrlMatch: (name) ->
    @filter (res) -> _s.include(res.url, name)

  unique: (url) ->
    new WebResources(
      _.uniq @resources, (res) -> webutil.urlStrip(res.url)
    ).filter (res) -> res.url != url

  uncrawled: ->
    @links().filter (link) -> link.crawled != true

  sort: (fn) ->
    new WebResources(
      _.sortBy @resources, fn
    )

  length: ->
    @resources.length

  take: (limit) ->
    new WebResources(
      _.take @resources, limit
    )
    
  interesting: (limit) ->
    followLinks = @links()

    if followLinks.length() < limit
      followLinks = followLinks.sort((link) -> link.url.length).take(limit)

    if followLinks.length() > limit
      followLinks = followLinks.keyworded(limit).take(limit)

    followLinks

  keyworded: ->
    @filter (link) ->
      _.findWhere linkKeywords, (word) ->
        _s.include(URL.parse(link.url).path, word) || _s.include(link.text, word) || _s.include(link.id, word)

  withDomain: (domain) ->
    @filter (link) ->
      _s.include webutil.domain(link.url), domain


# ==== EXPORT

module.exports = (array) -> new WebResources(array)
