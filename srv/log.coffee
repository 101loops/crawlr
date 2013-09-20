# ==== EXPORT

module.exports = (msg, ctx) ->
  logMsg = msg
  if ctx
    logMsg = "[" + ctx + "] " + msg
  console.log(logMsg)