local GNUI = require"GNUI.main"
local Button = require "GNUI.element.button"

---@param app TV.app
---@param window GNUI.Box
---@param screen GNUI.Canvas
---@param skull WorldSkull
return function (app,window,screen,skull)
  window.Nineslice:setTexture(textures["textures.firewatch_pixelated"])
  for i = 1, 5, 1 do
    Button.new(window):setPos(10,i*21):setSize(40,20):setText("Lmao "..i)
  end
end