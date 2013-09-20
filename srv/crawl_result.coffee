_ = require("lodash")
log = require("./log")
webresources = require("./web_resources")


# ==== INTERFACE

class CrawlResult

  constructor: (url, meta, resources) ->
    @url = url
    @meta = meta
    @resources = resources ? webresources()

  isError: ->
    @meta.error != undefined

  set: (key, val) ->
    @meta[key] = val

  getResources: ->
    @resources

  merge: (result) ->
    @mergeResources(result.getResources())

  mergeResources: (resources) ->
    new CrawlResult @url, @meta, @resources.merge(resources)

  render: ->
    _.assign {resources: @resources.getList()}, @meta


# ==== EXPORT

module.exports = (url, meta, resources) -> new CrawlResult url, meta, resources


# ==== HELPERS