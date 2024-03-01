
---@param gnui GNUI
---@param events GNUI.TV.app
---@param screen GNUI.container
---@param skull WorldSkull
local function new(gnui,screen,events,skull)
   
end
avatar:store("gnui.app.calculator",{
   update = client:getSystemTime(),
   name   = "Calculator",
   new    = new,
   icon   = textures["textures.icons"],
   icon_atlas_pos = vectors.vec2(0,0)
})

--avatar:store("gnui.force_app","system:calculator")
--avatar:store("gnui.force_app",client:getViewer():getUUID()..":calculator")