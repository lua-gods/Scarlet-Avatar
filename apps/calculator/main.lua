local gnui = require("libraries.gnui")

---@class GNUI.TV.app
---@field TICK EventLib
---@field FRAME EventLib
---@field EXIT EventLib

---@param app GNUI.TV.app
---@return GNUI.TV.app
---@return string -- name
---@return Sprite -- icon
local function new(app)
   local icon = gnui.newSprite()
   icon:setTexture(textures.apps.calculator.icon)
   return app,"Example",icon
end

return new