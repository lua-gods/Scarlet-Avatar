local gnui = require("libraries.gnui")


---@param app GNUI.TV.app
---@param screen GNUI.container
---@return GNUI.TV.app
local function new(app,screen)
   
   return app
end
avatar:store("gnui.app.calculator",{
   update = client:getSystemTime(),
   name   = "Calculator",
   new    = new,
   icon   = textures["textures.icons"],
   icon_atlas_pos = vectors.vec2(0,0)
})