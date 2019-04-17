--[[
    Possible states of the seed:
        * sky
        * falling
        * touchdown
        * onthefloor
        * rotting
        * evolving
        * dead
--]]
local SeedClass = {
    x = 0,
    y = 0,
    vx = 10,
    vy = 0,
    width = 20,
    height = 20,
    image = love.graphics.newImage("assets/seed.png"),
    name = "Seed",
    isSeed = true,
    states = {
        sky = {
            name = "sky",
            quads = {
                {
                    quad = love.graphics.newQuad(130, 61, 14, 16, atlas:getDimensions()),
                    width = 14,
                    height = 16
                }
            },        
            load = function(self)
                self.currentframe = 1
                self.collisions_filter = function(item, other)
                    return "cross"
                end
            end,
            update = function(self, dt)
                if  self.x > WORLD_WIDTH then 
                    self.x = 0 - self.width
                end
                self.x, self.y, cols, len = self.world:move(self, self.x + self.vx * dt, self.y, self.collisions_filter)
            end,
        },
        falling = {
            name = "falling",
            quads = {
                {
                    quad = love.graphics.newQuad(98, 56, 14, 21, atlas:getDimensions()),
                    width = 14,
                    height = 21
                },
                {
                    quad = love.graphics.newQuad(114, 57, 14, 19, atlas:getDimensions()),
                    width = 14,
                    height = 19
                }
            },
            load = function(self) 
                self.current_frame = 1
                self.elapsed_time = 0
                self.collisions_filter = function(item, other)
                    if other.isSeed and other.state == other.states.sky then
                        return "cross"
                    else
                        return "slide"
                    end
                end
            end,
            update = function(self, dt)
                target_y = self.y + 100 * dt
                target_x = self.x
                self.y = target_y
                self.x = target_x
                self.x, self.y, cols, len = self.world:move(self, target_x, target_y, self.collisions_filter)
                if self.y + self.height >= WORLD_HEIGHT then
                    self.change_state(self, self.states.touchdown)
                    return
                end
                self.elapsed_time = self.elapsed_time + dt
                if self.elapsed_time > 0.5 then
                    --self.elapsed_time = self.elapsed_time - 0.5
                    self.elapsed_time = math.fmod(self.elapsed_time, 0.5)
                    self.current_frame = self.current_frame + 1
                    if self.current_frame > 2 then self.current_frame = 1 end
                end
            end
        },
        touchdown = {
            name = "touchdown",
            quads = {
                {
                    quad = love.graphics.newQuad(146, 65, 14, 14, atlas:getDimensions()),
                    width = 14,
                    height = 14
                }
            },
            load = function(self)
                self.currentframe = 1
            end,
            update = function(self, dt) 
                self.change_state(self, self.states.onthefloor)
            end
        },
        onthefloor = {
            name = "onthefloor",
            quads = {
                {
                    quad = love.graphics.newQuad(146, 65, 14, 14, atlas:getDimensions()),
                    width = 14,
                    height = 14
                }
            },
            load = function(self)
                self.elapsed_time = 0
                self.currentframe = 1 
            end,
            update = function(self, dt)
                self.elapsed_time = self.elapsed_time + dt
                if self.elapsed_time > 3 then
                    self.change_state(self, self.states.rotting)
                end
            end
        },
        rotting = {
            name = "rotting",
            quads = {
                {
                    quad = love.graphics.newQuad(161, 66, 15, 14, atlas:getDimensions()),
                    width = 15,
                    height = 14
                } 
            },
            load = function(self)
                self.elapsed_time = 0
                self.currentframe = 1
            end,
            update = function(self, dt)
                self.elapsed_time = self.elapsed_time + dt
                if self.elapsed_time > 2 then
                    self.sky:deleteSeed(self)
                end
            end
        },
        evolving = {
            name ="evolving",
            quads = {
                {
                    quad = love.graphics.newQuad(177, 67, 15, 13, atlas:getDimensions()),
                    width = 15,
                    height = 13
                }
            },
            load = function(self)
                self.currentframe = 1
            end,
            update = function(self, dt) end
        }
    }
}

SeedClass.__index = SeedClass

function SeedClass.new(name, sky, world, x, y)
    local seed = {}
    seed.name = name
    seed.sky = sky
    seed.world = world
    seed.x = x
    seed.y = y
    seed.world:add(seed, seed.x, seed.y, SeedClass.width, SeedClass.height)
    setmetatable(seed, SeedClass)
    --seed.state = SeedClass.states.sky
    seed.currentFrame = 1
    seed.change_state(seed, SeedClass.states.sky)
    return seed
end

function SeedClass:update(dt)
    self.state.update(self, dt)
end

function SeedClass:draw()
    --[[
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        0,
        self.width / self.image:getWidth(),
        self.height/ self.image:getHeight())
    --]]
    love.graphics.draw(
        atlas,
        self.state.quads[self.currentFrame].quad,
        self.x,
        self.y,
        0,
        self.width / self.state.quads[self.currentFrame].width,
        self.height/ self.state.quads[self.currentFrame].height
    )
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

end

function SeedClass:change_state(new_state)
    if self.state ~= new_state then
        self.state = new_state
        self.state.load(self)
    end
end

return SeedClass