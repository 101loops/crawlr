_s = require("underscore.string")
_ = require("lodash")

RSVP = require("rsvp")
log = require("./log")
webpage = require("./web_page")
webutil = require("./web_util")
webresources = require("./web_resources")


# ==== INTERFACE

class Crawler

  crawl: (opts, callback) ->

    # (0) prepare crawl options
    opts.root = _s.rtrim(opts.root, "/")
    if !opts.maxlinks
      opts.maxlinks = 10
    else
      opts.maxlinks = parseInt(opts.maxlinks)

    opts.domain = webutil.domain(opts.root)
    if !opts.brand
      opts.brand = webutil.host(opts.root)

    if !opts.maxdepth
      opts.maxdepth = 2
    else
      opts.maxdepth = parseInt(opts.maxdepth)

    # (1) - crawl root page
    (webpage(opts.root).crawl opts, 0).then (result) ->
      if result.isError()
        log "sub",
        callback 500, result
      else
        # (2) - crawl sub-pages
        crawlLinks = result.getResources().interesting(opts.domain, opts.maxlinks).withDomain(opts.domain)
        #console.log(crawlLinks)
        crawlPages result, crawlLinks, opts, 1, (result2) ->

          # (3) - crawl sub-sub-pages
          crawlLinks = result2.getResources().uncrawled().withDomain(opts.domain).keyworded().take(opts.maxlinks)
          crawlPages result2, crawlLinks, opts, 2, (result3) ->

            # (4) - crawl services
            #links = _.filter result.resources, (res) -> res.kind == "link"
            #result.resources = mergeLinks(result.resources, crawlNetworks(links, opts))

            callback 200, result3
    , (error) ->
      log error, opts.brand
      callback 500, error


# ==== EXPORT

module.exports = new Crawler


# ==== HELPERS

crawlPages = (result, resources, opts, depth, callback) ->
  if resources.length() > 0
    promises = []
    _(resources.getList()).each (res) ->
      res['crawled'] = true
      promises.push (webpage(res.url).crawl opts, depth)

    RSVP.all(promises).then (subResults) ->
      _(subResults).each (subResult) ->
        if !result.isError()
          result = result.merge(subResult)
      callback result
    , (error) ->
      log error, opts.brand
      callback result
  else
    callback result