local love = require("love")

function Laser(x, y, angle)
    local LASER_SPEED = 500
    local FPS = love.timer.getFPS()
    if FPS == 0 then FPS = 1 end -- Prevent division by zero

    return {
        x = x,
        y = y,
        x_vel = LASER_SPEED * math.cos(angle) / FPS,
        y_vel = LASER_SPEED * math.sin(angle) / FPS,
        distance_traveled = 0,
        radius = 3,

        draw = function(self, faded, enemy)
            local opacity = 1
            if faded then
                opacity = 0.5
            end

            love.graphics.setColor(1, 1, 1, opacity)
            love.graphics.setPointSize(3)
            love.graphics.points(self.x, self.y)
        end,

        update = function(self)
            self.x = self.x + self.x_vel 
            self.y = self.y - self.y_vel

            if self.x < 0 then
                self.x = love.graphics.getWidth() 
            elseif self.x > love.graphics.getWidth() then
                self.x = 0
            end

            if self.y < 0 then
                self.y = love.graphics.getHeight()
            elseif self.y > love.graphics.getHeight() then
                self.y = 0
            end

            self.distance_traveled = self.distance_traveled + math.sqrt(self.x_vel^2 + self.y_vel^2)
        end,

        collision = function(self, obj)

            -- Collision detection logic to be implemented
        end
    }

end
return Laser