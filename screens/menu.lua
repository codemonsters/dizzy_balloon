local PlayerClass = require("gameobjects/player")
local EnemyClass = require("gameobjects/enemy")
local bump = require("libraries/bump/bump")
local BlockClass = require("gameobjects/block")
local animLoader = require("misc/animationLoader")
local ourTheme = require("menus/ourTheme")

--[[
    Esta pantalla (menu) tiene distintos estados, por ejemplo para cargar menús y hacer transiciones entre ellos y mostrarlos.
    El estado actual se guarda en menu.screenState, pero debe cambiarse llamando a menu.changeScreenState(screenState) para que así se llame a la función load() del estado al que cambiamos.
    La variable menu.currentMenu apunta hacia el menú actual.
    En menu.nextMenu se guarda el menú hacia el que nos estamos moviendo (el cual una vez finalizada la transición se convertirá en menu.currentMenu).
]]
local menu = {
    name = "Pantalla menú principal"
}

menu.screenStates = {
    -- TODO: ¿Añadir efecto para utilizar mientras abandonamos esta pantalla?
    changingMenu = {
        -- transición de un menú a otro
        name = "chagingMenu",
        load = function()
            if menu.currentMenu == nil then
                -- entrando por primera vez en esta pantalla (o volviendo desde otro screen)
                -- desplazamiento del nuevo menú desde arriba
                menu.screenStates.changingMenu.effect = menu.screenStates.changingMenu.effects.moveDown
            elseif menu.currentMenu.name == "main" and menu.nextMenu.name == "preferences" then
                -- desplazamiento del nuevo menú hacia la izquierda
                menu.screenStates.changingMenu.effect = menu.screenStates.changingMenu.effects.moveLeft
            elseif menu.currentMenu.name == "preferences" and menu.nextMenu.name == "main" then
                -- desplazamiento del nuevo menú hacia la derecha
                menu.screenStates.changingMenu.effect = menu.screenStates.changingMenu.effects.moveRight
            else
                -- el nuevo menú sustituye al actual inmediatamente, sin animaciones
                menu.screenStates.changingMenu.effect = nil
                menu.currentMenu = menu.nextMenu
                menu.nextMenu = nil
                menu.changeScreenState(menu.screenStates.showingMenu)
            end
            menu.screenStates.changingMenu.effect.load()
        end,
        update = function(dt)
            menu.screenStates.changingMenu.effect.update(dt)
        end,
        draw = function()
            if menu.currentMenu then
                love.graphics.push()
                love.graphics.translate(
                    menu.screenStates.changingMenu.currentMenuShiftX,
                    menu.screenStates.changingMenu.currentMenuShiftY
                )
                menu.currentMenu.draw()
                love.graphics.pop()
            end

            love.graphics.push()
            love.graphics.translate(
                menu.screenStates.changingMenu.nextMenuShiftX,
                menu.screenStates.changingMenu.nextMenuShiftY
            )
            menu.nextMenu.draw()
            love.graphics.pop()
        end,
        effects = {
            moveDown = {
                load = function()
                    menu.screenStates.changingMenu.currentMenuShiftX = 0
                    menu.screenStates.changingMenu.currentMenuShiftY = 0
                    menu.screenStates.changingMenu.nextMenuShiftX = 0
                    menu.screenStates.changingMenu.nextMenuShiftY = -SCREEN_HEIGHT
                    menu.screenStates.changingMenu.velY = 1500
                end,
                update = function(dt)
                    menu.screenStates.changingMenu.nextMenuShiftY =
                        menu.screenStates.changingMenu.nextMenuShiftY + dt * menu.screenStates.changingMenu.velY
                    if menu.screenStates.changingMenu.nextMenuShiftY > 0 then
                        menu.currentMenu = menu.nextMenu
                        menu.nextMenu = nil
                        menu.changeScreenState(menu.screenStates.showingMenu)
                        menu.currentMenu.update(dt)
                    else
                        menu.nextMenu.update(dt)
                    end
                end
            },
            moveLeft = {
                load = function()
                    menu.screenStates.changingMenu.currentMenuShiftX = 0
                    menu.screenStates.changingMenu.nextMenuShiftX = SCREEN_WIDTH
                    menu.screenStates.changingMenu.velX = -2500
                end,
                update = function(dt)
                    menu.screenStates.changingMenu.currentMenuShiftX =
                        menu.screenStates.changingMenu.currentMenuShiftX + dt * menu.screenStates.changingMenu.velX
                    menu.screenStates.changingMenu.nextMenuShiftX =
                        menu.screenStates.changingMenu.nextMenuShiftX + dt * menu.screenStates.changingMenu.velX
                    if menu.screenStates.changingMenu.currentMenuShiftX <= -SCREEN_WIDTH then
                        menu.currentMenu = menu.nextMenu
                        menu.nextMenu = nil
                        menu.changeScreenState(menu.screenStates.showingMenu)
                        menu.currentMenu.update(dt)
                    else
                        menu.currentMenu.update(dt)
                        menu.nextMenu.update(dt)
                    end
                end
            },
            moveRight = {
                load = function()
                    menu.screenStates.changingMenu.currentMenuShiftX = 0
                    menu.screenStates.changingMenu.nextMenuShiftX = -SCREEN_WIDTH
                    menu.screenStates.changingMenu.velX = 2500
                end,
                update = function(dt)
                    menu.screenStates.changingMenu.currentMenuShiftX =
                        menu.screenStates.changingMenu.currentMenuShiftX + dt * menu.screenStates.changingMenu.velX
                    menu.screenStates.changingMenu.nextMenuShiftX =
                        menu.screenStates.changingMenu.nextMenuShiftX + dt * menu.screenStates.changingMenu.velX
                    if menu.screenStates.changingMenu.currentMenuShiftX >= SCREEN_WIDTH then
                        menu.currentMenu = menu.nextMenu
                        menu.nextMenu = nil
                        menu.changeScreenState(menu.screenStates.showingMenu)
                        menu.currentMenu.update(dt)
                    else
                        menu.currentMenu.update(dt)
                        menu.nextMenu.update(dt)
                    end
                end
            }
        }
    },
    showingMenu = {
        -- mostrando un menú
        name = "showingMenu",
        load = function()
        end,
        update = function(dt)
            menu.currentMenu.update(dt)
        end,
        draw = function()
            menu.currentMenu.draw()
        end
    }
}

function menu.changeMenu(nextMenu)
    menu.nextMenu = nextMenu
    -- transición de un menú a otro
    menu.changeScreenState(menu.screenStates.changingMenu)
end

-- carga un menú y ejecuta su método load antes de devolverlo
function menu.loadMenu(newMenu)
    local m = newMenu
    log.debug("cargando menú ''" .. m.name .. "'")
    m.load(menu) -- al menú le pasamos como argumento la pantalla para que pueda acceder a ella por ejemplo cuando ese menú quiere pedir que se cambie a otro distinto
    return m
end

function menu.changeScreenState(screenState)
    if screenState == nil then
        error("menu.changeScreenState() received a nil screenState argument")
    end
    menu.screenState = screenState
    menu.screenState.load()
end

-- carga este screen
function menu.load()
    -- música
    music = love.audio.newSource("assets/music/menu.mp3", "stream")
    music:setLooping(true)
    music:play()

    -- animaciones
    world = bump.newWorld(50)
    jugador = PlayerClass.new(world, nil)
    enemigo1 = EnemyClass.new(enemigo, SCREEN_WIDTH * 0.05, PlayerClass.height * 3, world, nil, 0)
    local borderWidth = 50
    BlockClass.new("Suelo", 0, WORLD_HEIGHT, SCREEN_WIDTH, borderWidth, world)
    BlockClass.new("ParedIzquierda", 0, 0, 1, SCREEN_HEIGHT, world)
    BlockClass.new("ParedDerecha", SCREEN_WIDTH, 0, 1, SCREEN_HEIGHT, world)
    BlockClass.new("Techo", 0, 0, SCREEN_WIDTH, 1, world)
    animLoader:applyAnim(enemigo1, animacionTestEnemigo)
    animLoader:applyAnim(jugador, animacionTestJugador) -- asocia el animador al jugador y cargar una animación en él

    -- estado inicial de los menús
    menu.currentMenu = nil -- forzamos currentMenu a nil para que changeMenu sepa que el menú que va a cargar es el primero de esta pantalla
    menu.changeMenu(menu.loadMenu(require("menus/main")))
end

function menu.update(dt)
    jugador:update(dt)
    enemigo1:update(dt)
    animLoader:update(dt)
    menu.screenState.update(dt)
end

function menu.draw()
    love.graphics.clear(1, 0, 1)

    love.graphics.push()
    love.graphics.translate(desplazamientoX, desplazamientoY)
    love.graphics.scale(factorEscala, factorEscala)
    love.graphics.setColor(255, 0, 0, 255)

    jugador:draw()
    enemigo1:draw()

    -- DEBUG: marcas en los extremos diagonales de la pantalla
    love.graphics.setColor(255, 0, 0)
    love.graphics.line(0, 0, 10, 0)
    love.graphics.line(0, 0, 0, 10)
    love.graphics.line(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, SCREEN_WIDTH - 11, SCREEN_HEIGHT - 1)
    love.graphics.line(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 11)

    menu.screenState.draw()

    love.graphics.pop()
end

function menu.keypressed(key, scancode, isrepeat)
    if menu.currentMenu then
        menu.currentMenu.keypressed(key, scancode, isrepeat)
    end
end

function menu.keyreleased(key, scancode, isrepeat)
    if menu.currentMenu then
        menu.currentMenu.keyreleased(key, scancode, isrepeat)
    end
end

return menu
