_s = require("underscore.string")
_ = require("lodash")

log = require("./log")
request = require("request")


# ==== INTERFACE

class WebUtil

  domain: (url) ->
    _s.strLeft(_s.strRight(url, "//"), "/")

  host: (url) ->
    _s.strRightBack(_s.strLeftBack(@domain(url), "."), ".")

  encode: (data) ->
    if data
      encodeURIComponent(_s.trim(data))
    else
      undefined

  absUrl: (urlRoot, path) ->
    if path
      if !_s.startsWith(path, "mailto:") && !_s.startsWith(path, "javascript:")
        url = path
        if !_s.startsWith(url, "http") && !_s.startsWith(url, "www")
          if !_s.startsWith(url, "/")
            url = "/" + url
          url = urlRoot + url
        url

  urlStrip: (url) ->
    (url ? "").replace("http://", "").replace("https://", "").replace("www.", "")

  fetch: (url, opts, callback) ->
    request
      url: url
      method: "GET"
      timeout: opts.timeout || 5000
    , callback


# ==== EXPORT

module.exports = new WebUtil