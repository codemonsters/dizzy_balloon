local menu = {
    name = "main",
    widgets = suit.new(require("menus/ourTheme"))
}

function menu.load(menuManager, screen)
    menu.menuManager = menuManager
    menu.screen = screen
end

function menu.update(dt)
    menu.widgets.layout:reset(SCREEN_WIDTH * 0.2, SCREEN_HEIGHT * 0.05)
    menu.widgets.layout:padding(0, SCREEN_WIDTH * 0.015)
    local mouseX, mouseY = love.mouse.getPosition()

    menu.widgets:updateMouse((mouseX - desplazamientoX) / factorEscala, (mouseY - desplazamientoY) / factorEscala)

    menu.widgets:Label("Dizzy Balloon", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.2))

    if menu.widgets:Button("Jugar", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        --music:stop()
        sounds.play(sounds.uiClick)
        --sounds.ui_click:play()
        menu.menuManager:changeMenuTo(
            nil,
            function()
                changeScreen(require("screens/game"))
                menu.menuManager:init()
            end,
            true
        )
    end
    if menu.widgets:Button("Preferencias", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        menu.menuManager:changeMenuTo(menu.menuManager:getMenu("preferences"))
    end
    if menu.widgets:Button("Instrucciones", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        menu.menuManager:changeMenuTo(menu.menuManager:getMenu("instructions"))
    end
    if menu.widgets:Button("Salir", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        os.exit()
    end
end

function menu.draw()
    love.graphics.setBlendMode("alpha")
    menu.widgets:draw()
end

function menu.keypressed(key, scancode, isrepeat)
    if key == "space" then
        music:stop()
        changeScreen(require("screens/game"))
    end
end

function menu.keyreleased(key, scancode, isrepeat)
end

return menu
