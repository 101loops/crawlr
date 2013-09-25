_s = require("underscore.string")
_ = require("lodash")

URL = require("url")
log = require("./log")
RSVP = require("rsvp")
cheerio = require("cheerio")
webutil = require("./web_util")
crawlresult = require("./crawl_result")
webresources = require("./web_resources")


# ==== INTERFACE

class WebPage

  constructor: (url) ->
    @url = url

  crawl: (opts, depth) ->
    self = @
    new RSVP.Promise (resolve, reject) ->
      log "crawling (" + depth + ") " + self.url, opts.brand
      webutil.fetch self.url, opts, (err, resp, body) ->
        result = undefined
        if err || resp?.statusCode == 404
          log "error crawling: " + self.url, opts.brand
          result = crawlresult self.url,
            error: err?.code || resp?.statusCode
        else
          $ = cheerio.load(body)
          result = crawlresult self.url, {}, findResources($, self.url, opts.root)

          # extract meta (only on root site)
          if depth == 0
            result.set "h1", findHeadings($, 1)
            result.set "h2", findHeadings($, 2)
            result.set "h3", findHeadings($, 3)

            result.set "title", webutil.encode($("title").html())
            result.set "keywords", webutil.encode(findMeta($, "name", "keywords")[0]?.content)
            result.set "description", webutil.encode(findMeta($, "name", "description")[0]?.content)

            result.mergeResources findMetaResources($, opts.root)

        resolve result

      return


# ==== EXPORT

module.exports = (url) -> new WebPage(url)


# ==== HELPERS

findResources = ($, url, urlRoot) ->
  findLinks($, url, urlRoot).merge(
    findImages($, url, urlRoot)
  ).merge(
    findFeeds($, url, urlRoot),
  ).merge(
    findMaps($, url, urlRoot)
  ).merge(
    findVideos($, url, urlRoot)
  )

findLinks = ($, url, urlRoot) ->
  links = webresources()
  $("a").each (i, link) ->
    linkUrl = $(link).attr("href")
    if linkUrl
      # cleanup link
      linkUrl = _s.strLeft(_s.rtrim(webutil.absUrl(urlRoot, linkUrl), "/").toLowerCase(), "#")

      # encode text
      linkText = webutil.encode(_s.clean(_s.trim($(link).text())))

      links.add
        kind: "link"
        id: $(link).attr("id")
        url: linkUrl
        text: linkText
        source: url
  links.unique()

findMaps = ($, url, urlRoot) ->
  maps = webresources()
  $("a").each (i, link) ->
    linkUrl = $(link).attr("href")
    if _s.include(linkUrl, "maps.google.com")
      urlObj = URL.parse(linkUrl, true)
      location = urlObj.query['sll'] || urlObj.query['ll']
      latitude = undefined
      longitude = undefined
      if location
        locObj = location.split(",")
        if locObj.length == 2
          latitude = locObj[0]
          longitude = locObj[1]

      maps.add
        kind: "map"
        source: url
        url: linkUrl
        longitude: longitude
        latitude: latitude
  maps.unique()

findVideos = ($, url, urlRoot) ->
  videos = webresources()
  # TODO
  videos.unique()

findImages = ($, url, urlRoot) ->
  images = webresources()
  $("img").each (i, img) ->
    imgSrc = $(img).attr("src")
    if imgSrc
      images.add
        kind: "image"
        source: url
        id: $(img).attr("id")
        alt: $(img).attr("alt")
        url: webutil.absUrl(urlRoot, imgSrc)
        width: $(img).attr("width")
        height: $(img).attr("height")
  images.unique().filter (img) -> (!img.width || !img.height) || (img.width > 25 && img.height > 25)

findFeeds = ($, url, urlRoot) ->
  feeds = webresources()
  _.each findTags($, "link", "rel", "alternate"), (tag) ->
    feeds.add
      kind: "feed"
      source: url
      type: tag?.type
      title: tag?.title
      url: webutil.absUrl(urlRoot, tag["href"])
  feeds.unique()

findHeadings = ($, level, path = "html") ->
  res = []
  $(path).find("h" + level).each (i, h) ->
    res.push(webutil.encode(_s.stripTags($(h).html())))
  res

findMetaResources = ($, urlRoot) ->
  resources = webresources()

  # extract 'image_src'
  _.each findTags($, "link", "rel", "image_src"), (tag) ->
    resources.add
      kind: "image"
      source: urlRoot
      url: webutil.absUrl(urlRoot, tag["href"])

  # extract 'apple-touch-icon'
  _.each findTags($, "link", "rel", "apple-touch-icon"), (tag) ->
    resources.add
      kind: "image"
      source: urlRoot
      url: webutil.absUrl(urlRoot, tag["href"])

  # extract 'og:image'
  _.each findTags($, "meta", "property", "og:image"), (tag) ->
    resources.add
      kind: "image"
      source: urlRoot
      url: webutil.absUrl(urlRoot, tag["content"])

  # TODO

  resources.unique()

findMeta = ($, prop, value) ->
  findTags($, "meta", prop, value)

findTags = ($, name, prop, value) ->
  result = []
  tag = $(name)
  keys = Object.keys(tag)
  keys.forEach (k) ->
    if tag[k].attribs
      if tag[k].attribs[prop] == value
        result.push tag[k].attribs
  result