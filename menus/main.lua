local menu = {
    name = "main",
    widgets = suit.new(require("menus/ourTheme"))
}

function menu.load(menuManager)
    menu.menuManager = menuManager
    --menu.canvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
end

function menu.update(dt)
    love.graphics.setBlendMode("alpha")

    menu.widgets.layout:reset(SCREEN_WIDTH * 0.2, SCREEN_HEIGHT * 0.05)
    menu.widgets.layout:padding(0, SCREEN_WIDTH * 0.015)
    local mouseX, mouseY = love.mouse.getPosition()

    menu.widgets:updateMouse((mouseX - desplazamientoX) / factorEscala, (mouseY - desplazamientoY) / factorEscala)

    menu.widgets:Label("Dizzy Balloon", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.2))

    if menu.widgets:Button("Jugar", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        --music:stop()
        sounds.ui_click:play()
        changeScreen(require("screens/game"))
    end
    if menu.widgets:Button("Preferencias", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        menu.menuManager:changeMenuTo(menu.menuManager:getMenu("preferences"))
    end
    if menu.widgets:Button("Instrucciones", menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)).hit then
        print("Te esperas. Todavía no está hecho. Si lo quieres usar, lo escribes y todos contentos :)")
    end
    if
        menu.widgets:Button(
            "Salir",
            {
                color = {
                    normal = {bg = {0, 0, 0, 0.15}, fg = {1, 1, 1}},
                    hovered = {fg = {1, 1, 1}, bg = {0.5, 0.5, 0.5, 0.5}},
                    active = {bg = {0, 0, 0, 0.5}, fg = {255, 255, 255}}
                }
            },
            menu.widgets.layout:row(SCREEN_WIDTH * .6, SCREEN_HEIGHT * 0.12)
        ).hit
     then
        sounds.ui_click:play()
        while sounds.ui_click:isPlaying() do end
        os.exit()
    end
end

function menu.draw()
    --love.graphics.setCanvas(menu.canvas)
    --do
        love.graphics.setBlendMode("alpha")
        menu.widgets:draw()
    --end
    --love.graphics.setCanvas()
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
