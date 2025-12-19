local love = require("love")

function love.conf(app)
  t.identify = 'data/saves'
  t.version = '0.0.1'

  app.window.length = 1280
  app.window.height = 720
  app.window.title = "Mage"
  app.window.display = 2

end