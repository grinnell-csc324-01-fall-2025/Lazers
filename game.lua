local love = require("love")
local Text = require("components/text")
local Enemy = require("objects/enemy")
function Game()
    _G.points = 0
    return {
        state = {
            menu = false,
            paused = false,
            running = true,
            game_over = false,
            countdown = true

        },

        countdown_timer = 1,
        countdown_value = 3,

        changeGameState = function(self, state)
            self.state.paused = state == 'paused'
            self.state.running = state == 'running'
            self.state.game_over = state == 'game_over'
            self.state.countdown = state == 'countdown'
        end,

        draw = function(self, faded)
            if self.state.countdown then
                Text(
                    tostring(self.countdown_value), 
                    0, 
                    love.graphics.getHeight() * 0.4, 
                    "h2", 
                    false, 
                    false, 
                    love.graphics.getWidth(), 
                    "center"
                ):draw()
            
            elseif faded and self.state.paused then
                Text(
                    "PAUSED", 
                    0, 
                    love.graphics.getHeight() * 0.4, 
                    "h1", 
                    false, 
                    false, 
                    love.graphics.getWidth(), 
                    "center"
                ):draw()
            end
        end,

        startNewGame = function(self, player)
            self:changeGameState('running')

            self.countdown_timer = 1   
            self.countdown_value = 3
            
        end,

        updateCountdown = function(self, dt, player)
            if self.state.countdown then
                self.countdown_timer = self.countdown_timer - dt
                if self.countdown_timer <= 0  then
                    self.countdown_value = self.countdown_value - 1
                    self.countdown_timer = 1

                    if self.countdown_value <= 0 then
                        self:changeGameState('running')
                    end
                end
            end
        end
    }
end
return Game