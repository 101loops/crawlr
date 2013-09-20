setup = require("./setup")
express = require("express")

PORT = process.env.PORT || 3000
SECRET = process.env.SECRET || "secret"

# ==== boot

app = module.exports = express()
setup app, SECRET

app.listen PORT, ->
  console.log "Listening on " + PORT