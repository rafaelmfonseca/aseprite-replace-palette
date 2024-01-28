local function pixelToColor(col)
    return Color {
        r = app.pixelColor.rgbaR(col),
        g = app.pixelColor.rgbaG(col),
        b = app.pixelColor.rgbaB(col),
        a = app.pixelColor.rgbaA(col)
    }
end

local function drawColor(dialog, i, col)
    local col = pixelToColor(col)
    dialog:color { id = "color_" .. tostring(i), color = col }
end

local function replaceColor(fromColor, toColor)
    app.command.ReplaceColor {
        ui = false,
        from = pixelToColor(fromColor),
        to = pixelToColor(toColor),
        tolerance = 0
    }
end

local function saveReplacePalette()
    local spr = app.activeSprite
    if not spr then
        return app.alert("There is no active sprite.")
    end

    local sel = spr.selection

    if sel.isEmpty then
        return app.alert("There is no selection.")
    end

    local img = Image(spr)
    local rect = sel.bounds

    local origColors = {}
    local replColors = {}

    local maxX = rect.x + rect.width - 1
    local maxY = rect.y + rect.height - 1

    for x = rect.x, maxX do
        for y = rect.y, maxY do
            if (x == rect.x) and (y % 2 == 0) then
                table.insert(origColors, img:getPixel(x, y))
            end
            if (x == rect.x + 3) and (y % 2 == 0) then
                table.insert(replColors, img:getPixel(x, y))
            end
        end
    end

    local dlg = Dialog("Replace Palette")

    for i in ipairs(origColors) do
        drawColor(dlg, i, origColors[i])
        drawColor(dlg, i, replColors[i])
        dlg:separator()
    end

    dlg:button {
        id="replace_palette",
        text="Replace All",
        onclick = function()
            app.transaction(function()
                for i in ipairs(origColors) do
                    replaceColor(origColors[i], replColors[i])
                end
            end)

            app.refresh()
        end
    }

    local bounds = dlg.bounds
    dlg.bounds = Rectangle(app.window.width - (bounds.width * 3), bounds.y, bounds.width, bounds.height)
    dlg:show({ wait = false })
end

function init(plugin)
    plugin:newCommand { id = "save_replace_palette", title = "Save [Replace Palette]", group = "sprite_size",
        onclick = function()
            saveReplacePalette();
        end
    }
end
