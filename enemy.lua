local love = require("love")
local Laser = require("objects/lasers")
local Player = require("objects/player")

function Enemy(x, y, size, type, debug)
    debug = debug or false
    local enemy_speed
    local vel = -1
    local enemy_vertices = 8
    local enemy_jag = 0.4
    local opacity

    
    if math.random() < 0.5 then
        vel = 1
    end

    if type == nil then
        type = "basic"
    end

    if type == "basic" then
        enemy_speed = math.random() + (50 * 1)
    elseif type == "spinner" then
        enemy_speed = math.random() + (50 * 2)
        enemy_vertices = 8
    end

    return {
        x = x,
        y = y,
        x_vel = math.random() * enemy_speed * vel,
        y_vel = math.random() * enemy_speed * vel,
        radius = math.ceil(size/2),
        --math is weird, taking the radian value of a point in a circle
        angle = math.rad(math.random(math.pi)),
        lasers = {},
        shot_timer = 0,
        shot_interval = 2,
        type = type,
       -- offset = offset,
        enemy_vertices = enemy_vertices,

        draw = function(self,faded)
            opacity = 1
        
            if faded then
                opacity = 0.2
            end

            if self.type == "basic" then
                love.graphics.setColor(1, 1, 1, opacity)

                love.graphics.rectangle(
                    "fill",
                    self.x - self.radius,
                    self.y - self.radius,
                    self.radius * 2,
                    self.radius * 2
                )

            elseif self.type == "spinner" then
                love.graphics.setColor(0, 1, 0, opacity)

                local points = {}
                for i = 0, 7 do -- 8 vertices for an octagon
                    local angle = self.angle + i * math.pi * 2 / 8 -- Divide the circle into 8 parts
                    table.insert(points, self.x + self.radius * 0.9 * math.cos(angle))
                    table.insert(points, self.y + self.radius * 0.9 * math.sin(angle))
                end
               -- for i = 0, self.enemy_vertices - 1 do
              --          local angle = self.angle + i * math.pi * 2 / self.enemy_vertices
             --           table.insert(points, self.x + self.radius * math.cos(angle))
             --           table.insert(points, self.y + self.radius * math.cos(angle))

              --  end

                love.graphics.polygon("line", points)
                
            end

            if debug then 
                love.graphics.setColor(1,0,0)
                love.graphics.circle("line", self.x, self.y, self.radius)
            end

            love.graphics.setColor(1, 0, 0)
            for _, laser in ipairs(self.lasers) do
                laser:draw()
            end
        end , 
        
        update = function(self, dt)
            -- Increment the angle to make the octagon spin
            if self.type == "spinner" then
                local rotation_speed = math.pi / 4-- Rotation speed in radians per second (180 degrees per second)
                self.angle = (self.angle + rotation_speed * dt) % (2 * math.pi)
                self.shot_interval = 1.5
                self.shot_timer = self.shot_timer + dt
                if self.shot_timer >= self.shot_interval then
                    for i = 0, 7 do
                    self:shoot(player)
                    self.shot_timer = 0
                    end
                end
            end

            if self.type == "basic" then
                self.shot_timer = self.shot_timer + dt
                if self.shot_timer >= self.shot_interval then
                    self:shoot(player)
                    self.shot_timer = 0
                end
            end

            for i = #self.lasers, 1, -1 do
                local laser = self.lasers[i]
                laser:update()

                if self:collision(laser, player) then
                    table.remove(self.lasers, i)
                    player:destroy()
                end
                if laser.x < 0 or laser.x > love.graphics.getWidth() or
                   laser.y < 0 or laser.y > love.graphics.getHeight() then
                    table.remove(self.lasers, i)
                end
                if laser.distance_traveled > 500 then
                    table.remove(self.lasers, i)
                end

            end

            --Update position (if needed)
            self.x = self.x + self.x_vel * dt
            self.y = self.y + self.y_vel * dt  

            if self.x <= 0 or self.x >= love.graphics.getWidth()then
                self.x_vel = -self.x_vel
            end

            if self.y <= 0 or self.y >= love.graphics.getHeight() then
                self.y_vel = -self.y_vel
            end

            for _, other in ipairs(enemies) do
                if other ~= self and self:enemyCollision(other) then
                        self.x_vel = -self.x_vel
                        self.y_vel = -self.y_vel
                        other.x_vel = -other.x_vel
                        other.y_vel = -other.y_vel
                    
                end
            end
        end,

        shoot = function(self, player)
            local dx
            local dy
            if self.type == "spinner" then
                local random_offset = math.random() * math.pi / 4 * 2
                local laser_angle = self.angle + random_offset
                dx = math.cos(laser_angle)
                dy = math.sin(laser_angle)
            else
                dx = player.x - self.x
                dy = player.y - self.y
                local magnitude = math.sqrt(dx * dx + dy * dy)

                if magnitude > 0 then
                    dx = dx / magnitude
                    dy = dy / magnitude
                end
            end

            local laser = Laser(self.x, self.y, dx, dy, 300)
            table.insert(self.lasers, laser)
        end,

        collision = function(self, laser, target)
            local distance = math.sqrt((laser.x - target.x)^2 + (laser.y - target.y)^2)
            return distance < (laser.radius + target.radius)

        end,

        enemyCollision = function(self, other)
            local distance = math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2)
            return distance < (self.radius + other.radius)
        end
    }
end

return Enemy
