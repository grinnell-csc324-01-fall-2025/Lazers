--Declare the love2d global variable
_G.love = require("love")
local Player = require("objects/player")
local Game = require("game")
local Laser = require("objects/lasers")
local Enemy = require("objects/enemy")
_G.DEBUG = true;


math.randomseed(os.time());
_G.enemies = {}
_G.spawn_timer = 0
_G.spawn_interval = 3

--Information about the game is loaded on start up here
function love.load()
  --set background color
  love.graphics.setBackgroundColor(0, 0, 0); 
  --love.update()
  love.mouse.setVisible(false);
  mouse_x, mouse_y = 0,0;

  player = Player(DEBUG);
  game = Game();
  game:startNewGame(player);
  text = Text();

 
end

function love.keypressed(key)
  if game.state.running then
    if key == "escape" then
      game:changeGameState('paused');
    end
    if key == "w" then
      player.moving = true
    end
    if key == "space" then
      player:draw_laser();
    end
  elseif game.state.paused then
    if key == "escape" then
      game:changeGameState('running');
    end
  end
    
end

function love.keyreleased(key)
  if key == "w" then
    player.moving = false
  end
end
--Called every 60 frames, achieving 60fps. (if load isnt intensive)
-- dt is the time between each frame
function love.update(dt)
  mouse_x, mouse_y = love.mouse.getPosition();
  --move player and enemies only if the game is running
  if game.state.running then
    player:move();
    for _, Enemy in pairs(enemies) do
        Enemy:update(dt)
    end
    -- Handle enemy spawning
    spawn_timer = spawn_timer + dt
    local type_choice = {"basic"}
    if spawn_timer >= spawn_interval then
      if points >= 10 then
        table.insert(type_choice, "spinner")
      end
      local enemy_x = math.random(50, love.graphics.getWidth() - 50) 
      local enemy_y = math.random(50, love.graphics.getHeight() - 50)
      local enemy_type = type_choice[math.random(1, #type_choice)]
      table.insert(enemies, Enemy(enemy_x, enemy_y, 20, enemy_type, DEBUG))
      spawn_timer = 0
    end
    
  end

  
end

--draws everything to the screen
function love.draw()

  -- Draw the objects only if the game is running or paused, if paused fade objects
  if game.state.running or game.state.paused then
    player:draw(game.state.paused);
    game:draw(game.state.paused)

    for _, Enemy in pairs(enemies) do
        Enemy:draw(game.state.paused)
    end
    --game over conditions
  elseif game.state.game_over then
    Text(
        "GAME OVER", 
        0, 
        love.graphics.getHeight() * 0.4, 
        "p", 
        false, 
        false, 
        love.graphics.getWidth(), 
        "center"
    ):draw()
    --player:draw(game.state.game_over);
    game:draw(game.state.game_over);

    for _, Enemy in pairs(enemies) do
        Enemy:draw(game.state.game_over)
    end


  end
  --draw stats, FPS for debugging
  love.graphics.setColor(1, 1, 1, 1)
  if DEBUG then
  love.graphics.print(love.timer.getFPS(), 10, 10)
  end
  love.graphics.print("Points: " .. tostring(_G.points), 10, 30)
  


  

  
end