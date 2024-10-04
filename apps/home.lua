local GNUI = require"GNUI.main"
local Button = require "GNUI.element.button"

---@param app TV.app
---@param window GNUI.Box
---@param screen GNUI.Canvas
---@param TVAPI TVAPI
---@param skull WorldSkull
return function (app,window,screen,TVAPI,skull)
  window.Nineslice:setTexture(textures["textures.firewatch_pixelated"])
  
  local apps = {}
  for _, path in pairs(listFiles("apps")) do
    local name = path:match("apps%.([^%.]+)")
    local _,pos = require("apps."..name)
    apps[#apps+1] = {name=name,pos=pos}
  end
    
  local tray = GNUI.newBox(window)
  :setAnchor(0,0,1,1)
  :setDimensions(10,10,-10,-10)
    
  for i = 1, #apps, 1 do
    local a = apps[i]
    local p = a.pos * 10
    local icon = GNUI.newNineslice(textures["textures.icons"],p.x-10,p.y-10,p.x-1,p.y-1)
    local button = Button.new(tray,"none"):setNineslice(icon):setSize(20,20):setPos((i-1)*30,0)
    
    button.PRESSED:register(function () TVAPI.setApp(a.name) end)
  end
  
  local function reposition()
    
  end
end,vec(1,1)