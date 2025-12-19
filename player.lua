local love = require("love")
local Laser = require("objects/lasers")

function Player(debugging)
    local PLAYER_SIZE = 20
    local VIEW_ANGLE = math.rad(90)

    debugging = debugging or false


    return {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        radius = PLAYER_SIZE / 2,
        angle = VIEW_ANGLE,
        moving = false,
        movement = {
            x = 0,
            y = 0,
            speed = 5,
            dashing = false,
            trail = 2.0
        },
        lasers = {},
        enemyCollision = function(self, other)
            local distance = math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2)
            return distance < (self.radius + other.radius)
        end,
        collision = function(self, laser, target)
            local distance = math.sqrt((laser.x - target.x)^2 + (laser.y - target.y)^2)
            return distance < (laser.radius + target.radius)
        end,
        
        destroy = function(self)
            game:changeGameState('game_over')
        end,
    
        draw_laser = function(self, laser, faded)
            table.insert(self.lasers, Laser(
                self.x,
                self.y,
                self.angle
            ))
        end,

        draw_dash = function(self, fill)
            love.graphics.setColor(255/255, 102/255, 25/255, 0.7)

            love.graphics.polygon(
                "line", 
                self.x - self.radius * (2/3 * math.cos(self.angle) + 0.5 * math.sin(self.angle)),
                self.y + self.radius * (2/3 * math.sin(self.angle) - 0.5 * math.cos(self.angle)),
                self.x - self.radius * (self.movement.trail * math.cos(self.angle)),
                self.y + self.radius * (self.movement.trail * math.sin(self.angle)),
                self.x - self.radius * (2/3 * math.cos(self.angle) - 0.5 * math.sin(self.angle)),
                self.y + self.radius * (2/3 * math.sin(self.angle) + 0.5 * math.cos(self.angle))
            )
        end,

        draw = function (self, fade)
            local opacity = 1

            if fade then
                opacity = 0.2
            end

            if self.moving then
                self.movement.trail = 2.0
                if not self.movement.dashing then
                    self.movement.trail = self.movement.trail - 1 / love.timer.getFPS()

                    if self.movement.trail < 1.5 then
                        self.movement.dash = true
                    end
                else
                    self.movement.trail =  self.movement.trail + 1 / love.timer.getFPS()        
                
                    if self.movement.trail > 1.5 then
                    self.movement.dash = false
                    end
                end
                self:draw_dash("fill", {255/255, 102/255, 25/255})
                --self:draw_dash("line", {1, 0.16, 0})
            else
                self.movement.trail = 0
            
            end



            love.graphics.setColor(1, 1, 1, opacity)
            love.graphics.polygon(
                "line", 
                self.x + ((4/3) * self.radius) * math.cos(self.angle), 
                self.y - ((4/3) * self.radius) * math.sin(self.angle),
                self.x - self.radius * (2/3 * math.cos(self.angle) + math.sin(self.angle)),
                self.y + self.radius * (2/3 * math.sin(self.angle) - math.cos(self.angle)),
                self.x - self.radius * (2/3 * math.cos(self.angle) - math.sin(self.angle)),
                self.y + self.radius * (2/3 * math.sin(self.angle) + math.cos(self.angle))
            )

            for _, laser in pairs(self.lasers) do
                laser:draw(faded)
            end

            if debugging then
                love.graphics.setColor(1,0,0)
                love.graphics.circle("line", self.x, self.y, self.radius)
            end
        end,

        move = function(self)
            local FPS = love.timer.getFPS()
            if FPS == 0 then FPS = 1 end -- Prevent division by zero
            local friction = .25

            local rotation = 360/180 * math.pi / FPS

            if love.keyboard.isDown("a") then
                self.angle = self.angle + rotation
                self.angle = self.angle % (2 * math.pi)
            end

            if love.keyboard.isDown("d") then
                self.angle = self.angle - rotation
                self.angle = self.angle % (2 * math.pi)
            end

            if self.moving then
                self.movement.x = self.movement.x + self.movement.speed * math.cos(self.angle) / FPS
                self.movement.y = self.movement.y - self.movement.speed * math.sin(self.angle) / FPS
            else
                if self.movement.x ~= 0 or self.movement.y ~= 0 then
                    self.movement.x = self.movement.x - friction * self.movement.x / FPS
                    self.movement.y = self.movement.y - friction * self.movement.y / FPS
                end
               -- self.movement.x = self.movement.x * friction
               -- self.movement.y = self.movement.y * friction
            end
            
            self.x = self.x + self.movement.x
            self.y = self.y + self.movement.y

            local screen_width = love.graphics.getWidth()
            local screen_height = love.graphics.getHeight()

            if self.x <= 0 or self.x >= screen_width then
                self.movement.x = 0
            end

            if self.y <= 0 or self.y >= screen_height then
                self.movement.y = 0
            end

            for index, laser in pairs(self.lasers) do
                laser:update()
                for i, enemy in ipairs(enemies) do
                    if self:collision(laser, enemy) or self:enemyCollision(enemy) then
                        if self:enemyCollision(laser, enemy) then
                            table.remove(enemies, i)
                            player:destroy()
                        end
                        table.remove(self.lasers, index)
                        table.remove(enemies, i)

                        if enemy.type == "spinner" then
                            _G.points = _G.points + 3
                        else
                            _G.points = _G.points + 2
                        end
                        break
                    end
                end
                
                if laser.distance_traveled > 800 then
                    table.remove(self.lasers, index)
                end
            end

         -- self.x = math.max(0, math.min(self.x, screen_width))
          --self.y = math.max(0, math.min(self.y, screen_height))
            
        end,
        
    }
end





return Player