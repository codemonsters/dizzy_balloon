local bump = require "libraries/bump/bump"
local game = {name = "Juego"}
local PlayerClass = require("gameobjects/player")
local EnemyClass = require("gameobjects/enemy")
local SkyClass = require("gameobjects/sky")
local PointerClass = require("pointer")
local BombClass = require("gameobjects/bomb")
local BalloonClass = require("gameobjects/balloon")
local MushroomClass = require("gameobjects/mushroom")
local GoalClass = require("gameobjects/goal")
local LimitClass = require("gameobjects/limit")
local LevelClass = require("level")
local LevelDefinitions = require("levelDefinitions")
local SoundsClass = require("sounds")
local sounds = SoundsClass.new()
local worldCanvas = nil
local hudCanvas = nil
local jugadorpuedesaltar = true
local jugadorquieremoverse = false
local BlockClass = require("gameobjects/block")
local gameFilter
local temporizador_respawn_enemigo = 0
local TIEMPO_RESPAWN_ENEMIGO = 1
local inicioCambioNivel = 0
local finalCambioNivel = 5
local state
local gamepad = love.graphics.newImage("assets/gamepad.png")
local circle = love.graphics.newImage("assets/circle.png")

local hud_width = (SCREEN_WIDTH - WORLD_WIDTH) / 2
local hud_height = SCREEN_HEIGHT

if mobile then
    leftFinger = PointerClass.new(game, "Izquierdo")
    rightFinger = PointerClass.new(game, "Derecho")
else
    mousepointer = PointerClass.new(game, "Puntero")
end

game.states = {
    jugando = {
        name = "Jugando",
        load = function(self)
            love.graphics.clear(0, 0, 0)
        end,
        update = function(self, dt)
            -- comprobamos si debemos crear un enemigo nuevo
            if game.currentLevel.max_enemies > #game.currentLevel.enemies then
                temporizador_respawn_enemigo = temporizador_respawn_enemigo + dt
                if temporizador_respawn_enemigo > TIEMPO_RESPAWN_ENEMIGO then
                    if math.random() > 0.5 then
                        enemigo =
                            EnemyClass.new(
                            "enemigoIzq",
                            EnemyClass.width,
                            EnemyClass.height,
                            game.currentLevel.world,
                            game,
                            math.random() * 360
                        )
                    else
                        enemigo =
                            EnemyClass.new(
                            "enemigoDer",
                            WORLD_WIDTH - EnemyClass.width,
                            EnemyClass.height,
                            game.currentLevel.world,
                            game,
                            math.random() * 360
                        )
                    end
                    table.insert(game.currentLevel.enemies, enemigo)
                    temporizador_respawn_enemigo = 0
                end
            end

            game.currentLevel.player:update(dt)

            for i, enemy in ipairs(game.currentLevel.enemies) do
                enemy:update(dt)
            end

            for i, balloon in ipairs(game.currentLevel.balloons) do
                balloon:update(dt)
            end
            if game.currentLevel.sky ~= nil then
                game.currentLevel.sky:update(dt)
            end

            for i, mushroom in ipairs(game.currentLevel.mushrooms) do
                mushroom:update(dt)
            end

            if fireRequested then
                fireRequested = false
                if
                    game.currentLevel.bomb.state == game.currentLevel.bomb.states.inactive and
                        not (game.currentLevel.player.montado and game.currentLevel.player.montura.isBalloon)
                 then
                    x, y = game.currentLevel.player.x, game.currentLevel.player.y
                    if fireInitialDirection == "down" then
                        if not game.currentLevel.player.not_supported then
                            game.currentLevel.player.x, game.currentLevel.player.y =
                                game.currentLevel.world:move(
                                game.currentLevel.player,
                                game.currentLevel.player.x,
                                game.currentLevel.player.y - game.currentLevel.bomb.height * 1.05
                            )
                            game.currentLevel.bomb:launch(
                                x,
                                y,
                                fireInitialDirection,
                                game.currentLevel.player:vx(),
                                game.currentLevel.player:vy()
                            )
                        end
                    elseif game.bombasAereas > 0 then
                        game.currentLevel.bomb:launch(
                            x,
                            y,
                            fireInitialDirection,
                            game.currentLevel.player:vx(),
                            game.currentLevel.player:vy()
                        )
                        game.bombasAereas = game.bombasAereas - 1
                    end
                end
            end
            game.currentLevel.bomb:update(dt)
        end,
        draw = function(self)
            love.graphics.setCanvas(game.currentLevel.worldCanvas) -- a partir de ahora dibujamos en el canvas
            do
                love.graphics.setBlendMode("alpha")

                -- El fondo del mundo
                love.graphics.setColor(192, 0, 109)
                love.graphics.rectangle("fill", 0, 0, WORLD_WIDTH, WORLD_HEIGHT)

                -- objetos del juego

                game.currentLevel.player:draw()

                for i, enemy in ipairs(game.currentLevel.enemies) do
                    enemy:draw()
                end

                for i, balloon in ipairs(game.currentLevel.balloons) do
                    balloon:draw()
                end
                if game.currentLevel.sky ~= nil then
                    game.currentLevel.sky:draw()
                end

                for i, block in ipairs(game.currentLevel.blocks) do
                    block:draw()
                end

                game.currentLevel.bomb:draw()

                for i, mushroom in ipairs(game.currentLevel.mushrooms) do
                    mushroom:draw()
                end

            end
            love.graphics.setCanvas() -- volvemos a dibujar en la ventana principal

            love.graphics.push()
            love.graphics.translate(desplazamientoX, desplazamientoY)
            love.graphics.scale(factorEscala, factorEscala)
            love.graphics.setBlendMode("alpha", "premultiplied")
            love.graphics.draw(
                game.currentLevel.worldCanvas,
                (SCREEN_WIDTH - WORLD_WIDTH) / 2,
                (SCREEN_HEIGHT - WORLD_HEIGHT) / 2,
                0,
                1,
                1
            )

            love.graphics.pop()
        end
    },
    cambiandoDeNivel = {
        load = function(self) -- cargamos el siguiente nivel y dibujamos su primer frame
            if game.currentLevel.music ~= nil then
                game.currentLevel.music:stop()
            end
            if LevelDefinitions[(game.currentLevel.id + 1)] == nil then
                game.nextLevel = game.loadlevel(LevelClass.new(LevelDefinitions[1], game))
            else
                game.nextLevel = game.loadlevel(LevelClass.new(LevelDefinitions[(game.currentLevel.id + 1)], game))
            end
            desplazamiento = 0

            love.graphics.setCanvas(game.nextLevel.worldCanvas)
            do
                love.graphics.setColor(192, 0, 109)
                love.graphics.rectangle("fill", 0, 0, WORLD_WIDTH, WORLD_HEIGHT)
                -- objetos del juego
                love.graphics.setColor(255, 255, 255)

                if game.nextLevel.sky ~= nil then
                    game.nextLevel.sky:draw()
                end

                for i, block in ipairs(game.nextLevel.blocks) do
                    block:draw()
                end

            end
            love.graphics.setCanvas() -- volvemos a dibujar en la ventana principal
            love.graphics.push()
            love.graphics.draw(
                game.currentLevel.worldCanvas,
                (SCREEN_WIDTH - WORLD_WIDTH) / 2,
                (SCREEN_HEIGHT - WORLD_HEIGHT) / 2 + desplazamiento,
                0,
                1,
                1
            )
            love.graphics.pop()
        end,
        update = function(self, dt)
            desplazamiento = desplazamiento + dt * 1000

            if desplazamiento >= WORLD_HEIGHT then
                posX = game.currentLevel.player.x
                game.currentLevel = game.nextLevel
                game.loadlife(posX)
                if game.currentLevel.music ~= nil then
                    game.currentLevel.music:play()
                end
                game.change_state(game.states.jugando)
            end
        end,
        draw = function(self)

            love.graphics.translate(desplazamientoX, desplazamientoY)
            love.graphics.scale(factorEscala, factorEscala)
            love.graphics.setBlendMode("alpha", "premultiplied")

            love.graphics.setCanvas() -- volvemos a dibujar en la ventana principal
            love.graphics.push()
            
            love.graphics.draw( -- el primer frame del anterior nivel es dibujado ya que sigue en memoria
                game.currentLevel.worldCanvas,
                (SCREEN_WIDTH - WORLD_WIDTH) / 2,
                (SCREEN_HEIGHT - WORLD_HEIGHT) / 2 + desplazamiento,
                0,
                1,
                1
            )
            love.graphics.draw(
                game.nextLevel.worldCanvas,
                (SCREEN_WIDTH - WORLD_WIDTH) / 2,
                -WORLD_HEIGHT + desplazamiento,
                0,
                1,
                1
            )

            love.graphics.pop()
        end
    }
}

function game.getNewRespawnPos()
    local respawnX, respawnY = game.currentLevel.player.x, game.currentLevel.player.y
    local cols, len = game.currentLevel.player.world:queryRect(
        game.currentLevel.player.x,
        game.currentLevel.player.y,
        game.currentLevel.player.width,
        game.currentLevel.player.height
    )
    for i = 1, len do
        if not cols[i].isPlayer then
            if cols[i].x + cols[i].width <= WORLD_WIDTH - game.currentLevel.player.width then
                respawnX = cols[i].x + cols[i].width
            else
                respawnY = cols[i].y - game.currentLevel.player.height
                respawnX = nivel_actual.jugador_posicion_inicial[1]
            end
        end
    end
    return respawnX, respawnY
end

function game.loadlife(posX)
    if posX == nil then
        game.currentLevel.player.x = game.currentLevel.player_initial_respawn_position[1]
    else
        game.currentLevel.player.x = posX
    end
    game.currentLevel.player.y = game.currentLevel.player_initial_respawn_position[2]
    game.currentLevel.player.x, game.currentLevel.player.y = game.getNewRespawnPos()
    game.currentLevel.world:update(
        game.currentLevel.player,
        game.currentLevel.player.x,
        game.currentLevel.player.y,
        game.currentLevel.player.width,
        game.currentLevel.player.height
    )
end

function game.loadlevel(level)
    level.player = PlayerClass.new(level.world, game)
    level.bomb = BombClass.new("Bomb", level.world, game)
    print(level.music)
    if level.music ~= nil then
        level.music = love.audio.newSource("assets/music/" .. level.music, "stream")
        level.music:setLooping(true)
    end
    
    local borderWidth = 50
    table.insert(
        level.blocks,
        BlockClass.new(
            "Suelo",
            -borderWidth,
            WORLD_HEIGHT,
            WORLD_WIDTH + 2 * borderWidth,
            borderWidth,
            level.world
        )
    )
    table.insert(
        level.blocks,
        BlockClass.new(
            "Pared Izquierda",
            -borderWidth,
            -borderWidth,
            borderWidth,
            WORLD_HEIGHT + 2 * borderWidth,
            level.world
        )
    )
    table.insert(
        level.blocks,
        BlockClass.new(
            "Pared Derecha",
            WORLD_WIDTH,
            -borderWidth,
            borderWidth,
            WORLD_HEIGHT + 2 * borderWidth,
            level.world
        )
    )

    return level
end

function game.load()
    hudCanvas = love.graphics.newCanvas(hud_width, hud_height)
    gamepadCanvas = love.graphics.newCanvas(hud_width, hud_height)
    game.vidas = 3
    game.bombasAereas = 9
    game.currentLevel = LevelClass.new(LevelDefinitions[1], game)
    game.loadlevel(game.currentLevel)
    game.change_state(game.states.jugando)
    if game.currentLevel.music ~= nil then
        game.currentLevel.music:play()
    end
    --game.state = game.states.cambiandoDeNivel
    --game.change_state(game.state)
end

function game.update(dt)
    game.state.update(game, dt)
end

function game.draw()
    love.graphics.clear(0, 0, 0) -- borramos la pantalla por completo

    love.graphics.setCanvas(hudCanvas) -- canvas del HUD
    do
        love.graphics.setBlendMode("alpha")

        -- El fondo del canvas
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, hud_width, SCREEN_HEIGHT)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("LVL - " .. game.currentLevel.id, font_hud, 0, 100, hud_width, "center")
        love.graphics.printf("x " .. game.vidas, font_hud, 140, 160, hud_width, "left")
        love.graphics.printf("x " .. game.bombasAereas, font_hud, 140, 220, hud_width, "left")

        ------------
        love.graphics.draw(atlas, PlayerClass.states.standing.quads[1].quad, 95, 154, 0, 2, 2) -- dibujamos el jugador en el hud

        love.graphics.draw(atlas, BombClass.states.planted.quads[1].quad, 94, 216, 0, 3, 3) -- dibujamos la bomba en el hud

        love.graphics.setColor(255, 0, 0)
        love.graphics.draw(circle, 35, SCREEN_HEIGHT - 280, 0, 1, 1)
        love.graphics.setColor(255, 255, 255)
        
    end

    love.graphics.setCanvas(gamepadCanvas) -- canvas del gamepad
    do
        love.graphics.setBlendMode("alpha")

        -- El fondo del canvas
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, hud_width, SCREEN_HEIGHT)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(gamepad, 35, SCREEN_HEIGHT - 280, 0, 1, 1)
    end

    love.graphics.setCanvas() -- volvemos a dibujar en la ventana principal

    love.graphics.push()
    love.graphics.translate(desplazamientoX, desplazamientoY)
    love.graphics.scale(factorEscala, factorEscala)

    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(hudCanvas, SCREEN_WIDTH - hud_width, 0, 0, 1, 1)
    love.graphics.draw(gamepadCanvas, 0, 0, 0, 1, 1)
    love.graphics.pop()

    game.state.draw(game)
end

function game.keypressed(key, scancode, isrepeat)
    if key == "q" then
        returnToMenu()
    elseif key == "w" or key == "up" then
        game.currentLevel.player.up = true
        fireRequested = true
        fireInitialDirection = "up"
    elseif key == "a" or key == "left" then
        game.currentLevel.player.left = true
    elseif key == "s" or key == "down" then
        game.currentLevel.player.down = true
        fireRequested = true
        fireInitialDirection = "down"
    elseif key == "d" or key == "right" then
        game.currentLevel.player.right = true
    elseif key == "space" then
        game.currentLevel.player:jump()
    elseif key == "v" then
        -- TODO: Eliminar esto en la versión pública
        game.vidas = game.vidas - 1
        log.debug("game.vidas: " .. game.vidas)
    elseif key == "b" then
        -- TODO: Eliminar esto en la versión pública
        game.vidas = game.vidas + 1
        log.debug("game.vidas: " .. game.vidas)
    elseif key == "l" then
        -- TODO: Eliminar esto en la versión pública
        game.change_state(game.states.cambiandoDeNivel)
    elseif key == "z" then
        print("Posición del jugador (x, y) = " .. game.currentLevel.player.x .. ", " .. game.currentLevel.player.y)
    end
end

function game.keyreleased(key, scancode, isrepeat)
    if key == "q" then
        returnToMenu()
    elseif key == "w" or key == "up" then
        game.currentLevel.player.up = false
    elseif key == "a" or key == "left" then
        game.currentLevel.player.left = false
    elseif key == "s" or key == "down" then
        game.currentLevel.player.down = false
    elseif key == "d" or key == "right" then
        game.currentLevel.player.right = false
    end
end

function game.cambioDeNivel()
    finalCambioNivel = love.timer.getTime()
    if finalCambioNivel - inicioCambioNivel >= 5 then
        inicioCambioNivel = love.timer.getTime()
        game.change_state(game.states.cambiandoDeNivel)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not mobile then
        jugadorquieremoverse = true
        --jugadorquieredisparar = true
        mousepointer:touchpressed(x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 and not mobile then
        jugadorquieremoverse = false
        --jugadorquieredisparar = false
        mousepointer:touchreleased(dx, dy)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not mobile then
        mousepointer:touchmoved(dx, dy)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    leftFinger:touchmoved(dx, dy)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if x > SCREEN_WIDTH / 2 then
        rightFinger:touchpressed(x, y)
    else
        jugadorquieremoverse = true
        --jugadorquieredisparar = true
        leftFinger:touchpressed(x, y)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if x > SCREEN_WIDTH / 2 then
        rightFinger:touchreleased(dx, dy)
    else
        jugadorquieremoverse = false
        --jugadorquieredisparar = false
        leftFinger:touchreleased(dx, dy)
    end
end

function game.pointerpressed(pointer)
    if pointer.x > SCREEN_WIDTH / 2 then
        game.currentLevel.player:jump()
    end
end

function game.pointerreleased(pointer)
    if pointer.x < SCREEN_WIDTH / 2 then
        game.currentLevel.player.left,
            game.currentLevel.player.right,
            game.currentLevel.player.up,
            game.currentLevel.player.down = false, false, false, false
    else
        jugadorpuedesaltar = true
    end
end

function game.pointermoved(pointer)
    if pointer.x < SCREEN_WIDTH / 2 then
        if jugadorquieremoverse == true then
            if pointer.x + pointer.movementdeadzone < pointer.x + pointer.dx then
                game.currentLevel.player.right = true
            else
                game.currentLevel.player.right = false
            end

            if pointer.x - pointer.movementdeadzone > pointer.x + pointer.dx then
                game.currentLevel.player.left = true
            else
                game.currentLevel.player.left = false
            end

            if pointer.y + pointer.movementdeadzone < pointer.y + pointer.dy then
                game.currentLevel.player.down = true
            else
                game.currentLevel.player.down = false
            end

            if pointer.y - pointer.movementdeadzone > pointer.y + pointer.dy then
                game.currentLevel.player.up = true
            else
                game.currentLevel.player.up = false
            end
        end
        if pointer.y + pointer.shootingdeadzone < pointer.y + pointer.dy then
            fireRequested = true
            fireInitialDirection = "down"
        elseif pointer.y - pointer.shootingdeadzone > pointer.y + pointer.dy then
            fireRequested = true
            fireInitialDirection = "up"
        end
    end
end

function game.vidaperdida()
    game.vidas = game.vidas - 1
    if game.vidas <= 0 then
        temporizador_respawn_enemigo = 0
        returnToMenu()
    else
        game.currentLevel.player:revive()
        game.loadlife()
    end
end

function game.remove_enemy(enemy)
    for i, v in ipairs(game.currentLevel.enemies) do
        if v == enemy then
            game.currentLevel.world:remove(enemy)
            table.remove(game.currentLevel.enemies, i)
            break
        end
    end
end

function game.remove_balloon(balloon)
    for i, v in ipairs(game.currentLevel.balloons) do
        if v == balloon then
            game.currentLevel.world:remove(balloon)
            table.remove(game.currentLevel.balloons, i)
            break
        end
    end
end

function game.create_balloon_from_seed(seed)
    local balloon = BalloonClass.new(seed, game.currentLevel.world, game)
    table.insert(game.currentLevel.balloons, balloon)
    seed:die()
end

function game.remove_mushroom(mushroom)
    for i, v in ipairs(game.currentLevel.mushrooms) do
        if v == mushroom then
            game.currentLevel.world:remove(mushroom)
            table.remove(game.currentLevel.mushrooms, i)
            break
        end
    end
end

function game.kill_object(object)
    log.debug("Matando el objeto " .. object.name)

    if object.isEnemy then
        game.drop_seed(object.x)
    end

    object:die()
end

function game.drop_seed(x)
    for key, seed in pairs(game.currentLevel.sky.semillas) do --pseudocode
        if math.abs(seed.x - x) < seed.width / 2 then
            seed:change_state(seed.states.falling)
        end
    end
end

function game.crearSeta(x, y)
    seta = MushroomClass.new("Seta", game.currentLevel.world, game, x, y)
    table.insert(game.currentLevel.mushrooms, seta)
end

function game.change_state(new_state)
    if game.state ~= new_state then
        game.state = new_state
        game.state.load(self)
    end
end

function returnToMenu() change_screen(require("screens/menu"))
    if game.currentLevel.music ~= nil then
        game.currentLevel.music:stop()
    end
end

return game
