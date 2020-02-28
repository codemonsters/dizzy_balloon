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
    name = "Seed",
    isSeed = true,
    powerUp = nil,
    player_over_timer = 0,
    states = {
        sky = {
            name = "sky",
            quads = {
                quads.egg
                --[[{
                    --quad = love.graphics.newQuad(130, 61, 14, 16, atlasOld:getDimensions()),
                    quad = love.graphics.newQuad(499, 499, 20, 20, atlasOld:getDimensions()),
                    width = 14,
                    height = 16
                }
                --]]
            },
            load = function(self)
                self.currentframe = 1
                self.collisions_filter = function(item, other)
                    return "cross"
                end
            end,
            update = function(self, dt)
                if self.x > WORLD_WIDTH then
                    self.x = 0 - self.width
                end
                self.x, self.y, cols, len = self.world:move(self, self.x + self.vx * dt, self.y, self.collisions_filter)
            end
        },
        falling = {
            name = "falling",
            quads = {
                quads.egg
                --[[
                {
                    --quad = love.graphics.newQuad(98, 56, 14, 21, atlas:getDimensions()),
                    quad = love.graphics.newQuad(499, 499, 20, 20, atlas:getDimensions()),
                    width = 14,
                    height = 16
                },
                {
                    --quad = love.graphics.newQuad(114, 57, 14, 19, atlas:getDimensions()),
                    quad = love.graphics.newQuad(499, 499, 20, 20, atlas:getDimensions()),
                    width = 14,
                    height = 16
                }
                --]]
            },
            load = function(self)
                self.current_frame = 1
                self.elapsed_time = 0
                self.collisions_filter = function(item, other)
                    if other.isSeed and other.state == other.states.sky then
                        return "cross"
                    elseif other.isLimit then
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
                if self.y > self.height * 2 and len > 0 then -- la semilla se activará al contacto tras caer 2 veces su altura
                    self.change_state(self, self.states.touchdown)
                    return
                end
                self.elapsed_time = self.elapsed_time + dt
                if self.elapsed_time > 0.5 then
                    --self.elapsed_time = self.elapsed_time - 0.5
                    self.elapsed_time = math.fmod(self.elapsed_time, 0.5)
                    self.current_frame = self.current_frame + 1
                    if self.current_frame > 2 then
                        self.current_frame = 1
                    end
                end
            end
        },
        touchdown = {
            name = "touchdown",
            quads = {
                quads.egg
                --[[
                {
                    --quad = love.graphics.newQuad(146, 65, 14, 14, atlas:getDimensions()),
                    quad = love.graphics.newQuad(499, 499, 20, 20, atlas:getDimensions()),
                    width = 14,
                    height = 16
                }
                --]]
            },
            load = function(self)
                self.currentframe = 1
            end,
            update = function(self, dt)
                if self.powerUp ~= nil then
                    self.change_state(self, self.states.explode)
                else
                    self.change_state(self, self.states.onthefloor)
                end
            end
        },
        onthefloor = {
            name = "onthefloor",
            quads = {
                quads.egg
                --[[
                {

                    --quad = love.graphics.newQuad(146, 65, 14, 14, atlas:getDimensions()),
                    quad = love.graphics.newQuad(499, 499, 20, 20, atlas:getDimensions()),
                    width = 14,
                    height = 16
                }
                --]]
            },
            load = function(self)
                print("onthefloor.load")
                self.elapsed_time = 0
                self.currentframe = 1
                self.player_over_timer = 0
            end,
            update = function(self, dt)
                target_y = self.y + 100 * dt
                self.x, self.y, cols, len = self.world:move(self, self.x, target_y, self.collisions_filter)
                -- comprobamos si tenemos encima un jugador
                local player_over = false
                -- local items, len = world:querySegment(self.x, self.y - 1, self.x + self.width, self.y - 1)
                local items, len = self.world:queryRect(self.x, self.y - self.height / 3, self.width, self.height / 3)
                for i = 1, len do
                    if items[i].isPlayer then
                        player_over = true
                        self.player_over_timer = self.player_over_timer + dt
                        break
                    end
                end
                if player_over == false then
                    self.elapsed_time = self.elapsed_time + dt
                end
                --[[if player_over then
                    print("PLAYER OVER")
                else
                    print("PLAYER NOT OVER")
                end--]]
                if self.player_over_timer > 2 then
                    self.game.create_balloon_from_seed(self)
                    self.change_state(self, self.states.balloon)
                elseif self.elapsed_time > 5 then
                    self.change_state(self, self.states.rotting)
                end
            end
        },
        evolving = {
            name = "evolving",
            quads = {
                quads.balloon
                --[[
                {
                    --quad = love.graphics.newQuad(146, 65, 14, 14, atlas:getDimensions()),
                    quad = love.graphics.newQuad(499, 499, 20, 20, atlas:getDimensions()),
                    width = 14,
                    height = 16
                }
                --]]
            },
            load = function(self)
                print("evolving.load")
                self.currentframe = 1
                self.elapsed_time = 0
            end,
            update = function(self, dt)
                self.elapsed_time = self.elapsed_time + dt

                -- comprobamos si tenemos encima un jugador
                local player_over = true
                -- local items, len = world:querySegment(self.x, self.y - 1, self.x + self.width, self.y - 1)
                local items, len = self.world:queryRect(self.x, self.y - 2, self.x + self.width, self.y - 2)
                for i = 1, len do
                    if items[i].isPlayer then
                        player_over = true
                        break
                    end
                end
                self.player_over_timer = player_over

                if not self.player_over_timer then
                    self.change_state(self, self.states.rotting)
                elseif self.elapsed_time > 1 then
                    self.game.create_balloon_from_seed(self)
                    self.change_state(self, self.states.balloon)
                end
            end
        },
        balloon = {
            name = "balloon",
            quads = {
                quads.balloon
                --[[
                {
                    quad = love.graphics.newQuad(125, 78, 16, 16, atlas:getDimensions()),
                    width = 16,
                    height = 16
                }
                --]]
            },
            load = function(self)
                self.currentframe = 1
            end,
            update = function(self, dt)
            end
        },
        rotting = {
            name = "rotting",
            quads = {
                {
                    quad = love.graphics.newQuad(161, 66, 15, 14, atlasOld:getDimensions()),
                    width = 15,
                    height = 14
                }
            },
            load = function(self)
                print("*** ROTTING ***")
                self.elapsed_time = 0
                self.currentframe = 1
            end,
            update = function(self, dt)
                self.elapsed_time = self.elapsed_time + dt
                if self.elapsed_time > 2 then
                    self:die()
                end
            end
        },
        explode = {
            name = "explode",
            size = 200,
            quads = {
                {
                    quad = love.graphics.newQuad(130, 61, 14, 16, atlasOld:getDimensions()),
                    width = 14,
                    height = 16
                }
            },
            load = function(self)
                initialTime = 0
                canApply = true
                self.world:remove(self)
            end,
            update = function(self, dt)
                local items, lenColExplosion =
                    self.world:queryRect(
                    self.x - self.state.size / 2,
                    self.y - self.state.size / 2,
                    self.state.size,
                    self.state.size
                )
                for i = 1, lenColExplosion do
                    if items[i].isPlayer and canApply then
                        self.powerUp:apply(items[i])
                        canApply = false
                    end
                end
                initialTime = initialTime + dt
                if initialTime >= 0.3 then
                    self:die()
                end
            end
        }
    }
}

SeedClass.__index = SeedClass

function SeedClass.new(name, sky, world, x, y, game)
    local seed = {}
    seed.game = game
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
    if self.powerUp ~= nil then
        love.graphics.setColor(self.powerUp.color)
    end
    love.graphics.draw(
        atlas,
        self.state.quads[self.currentFrame].quad,
        self.x,
        self.y,
        0,
        --self.state.size,
        --self.state.size
        self.width / self.state.quads[self.currentFrame].width,
        self.height / self.state.quads[self.currentFrame].height
    )
    if self.state == self.states.explode then
        love.graphics.rectangle(
            "fill",
            self.x - self.state.size / 2,
            self.y - self.state.size / 2,
            self.state.size,
            self.state.size
        )
    end
    love.graphics.setColor(255, 255, 255)
    --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function SeedClass:change_state(new_state)
    if self.state ~= new_state then
        self.state = new_state
        self.state.load(self)
    end
end

function SeedClass:die()
    self.sky:deleteSeed(self)
end

return SeedClass
