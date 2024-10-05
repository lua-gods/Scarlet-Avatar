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
  
  local input = ""
  local output = GNUI.newBox(window):setAnchor(0,0,1,1/gridSize.y):setTextAlign(1,0.5)
  
  local function u()
    output:setText(input)
  end
  
  local actions = {
    {"<X]",function () 
      input = input:sub(1,-2)
      u()
      end,clr1},
    {"7",function () input = input.."7" u() end},
    {"8",function () input = input.."8" u() end},
    {"9",function () input = input.."9" u() end},
    {"/",function () input = input.."/" u() end,clr2},
    
    {"CA",function () input = "" u() end,clr1},
    {"4",function () input = input.."4" u() end},
    {"5",function () input = input.."5" u() end},
    {"6",function () input = input.."6" u() end},
    {"*",function () input = input.."*" u() end,clr2},
    
    {"%",function () input = "%" u() end,clr1},
    {"1",function () input = input.."1" u() end},
    {"2",function () input = input.."2" u() end},
    {"3",function () input = input.."3" u() end},
    {"-",function () input = input.."-" u() end,clr2},
    
    {"x",function () TVAPI.quit() end,clr1},
    {".",function () input = input.."." u() end},
    {"0",function () input = input.."0" u() end},
    {"=",function () 
      local fun = load("return "..input)
      local ok,out = pcall(fun)
      if ok then
        input = tostring(out)
        output:setText(input)
      end
      end,clr2},
    {"+",function () input = input.."+" u() end,clr2},
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