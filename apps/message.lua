local gnui = require("libraries.gnui")


---@param app GNUI.TV.app
---@param screen GNUI.container
---@return GNUI.TV.app
local function new(app,screen)
   
   return app
end
avatar:store("gnui.app.message",{
   update = client:getSystemTime(),
   name   = "no u cant\n open apps \n yet lmao \n I dont have \n Enough Time\n yet so\n enjoy this\n very long\n sorry letter\n to you\n from me\n   -GN",
   new    = new,
   id     = "gn.message",
   icon   = textures["textures.calculator"],
})