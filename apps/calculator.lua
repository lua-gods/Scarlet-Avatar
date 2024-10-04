local GNUI = require"GNUI.main"
local Button = require "GNUI.element.button"

local gridSize = vec(5,5)

local clr1 = "#ff4f4f"
local clr2 = "#efdada"

---@param app TV.app
---@param window GNUI.Box
---@param screen GNUI.Canvas
---@param TVAPI TVAPI
---@param skull WorldSkull
return function (app,window,screen,TVAPI,skull)
  
  local actions = {
    {"<X]",function () end,clr1},
    {"7",function () end},
    {"8",function () end},
    {"9",function () end},
    {"/",function () end,clr2},
    
    {"CA",function () end,clr1},
    {"4",function () end},
    {"5",function () end},
    {"6",function () end},
    {"*",function () end,clr2},
    
    {"C",function () end,clr1},
    {"1",function () end},
    {"2",function () end},
    {"3",function () end},
    {"-",function () end,clr2},
    
    {"x",function () TVAPI.quit() end,clr1},
    {".",function () end},
    {"0",function () end},
    {"=",function () end,clr2},
    {"+",function () end,clr2},
  }
  
  local i = 0
  for y = 1, gridSize.y-1, 1 do
    for x = 0, gridSize.x-1, 1 do
      i = i + 1
      local info = actions[i]
      local button = Button.new(window)
      button:setAnchor(
        x/gridSize.x,
        y/gridSize.y,
        x/gridSize.x+(1/gridSize.x),
        y/gridSize.y+(1/gridSize.y))
      
        if info then
        button:setText(info[1]).PRESSED:register(info[2])
        if info[3] then
          button:setColor(info[3])
        end
      end
    end
  end
end,vec(2,1)