local tween = require("libraries.GNTweenLib")

local gnui = require("libraries.gnui")

---@param events GNUI.TV.app
---@param screen GNUI.container
---@param skull WorldSkull
local function new(_,screen,events,skull)
   local grid_size = vectors.vec2(8,8)

   local i = 0

   for y = 1, grid_size.y, 1 do
      for x = 1, grid_size.x, 1 do
         i = i + 1
         local o = i
         
         local clr = vectors.vec3(math.random(),math.random(),math.random())
         local sprite = gnui.newSprite():setTexture(textures["textures.icons"]):setUV(0,10,2,13):setBorderThickness(1,1,1,2):setColor(clr)
         local button = gnui.newContainer():setSprite(sprite)
         button:setAnchor((x-0.99)/grid_size.x,(y-0.99)/grid_size.y,(x-0.01)/grid_size.x,(y-0.01)/grid_size.y)
         screen:addChild(button)
         local function press(ignore,mute,custom_clr)
            tween.tweenFunction(5,0,1,"outElastic",function (t,e)
               button:setDimensions(t,t,-t,-t)
               sprite:setColor(math.lerp(clr,custom_clr or vectors.vec3(1,1,1),math.max(1-e*5,0)))
            end,nil,"simon"..o)
            sounds:playSound("minecraft:block.note_block.xylophone",skull.pos,1,2^((o % 24 - 12)/12))
         end
         button.PRESSED:register(events.restart)
      end
   end
end
avatar:store("gnui.app.benchmark",{
   update = client:getSystemTime(),
   name   = "Benchmark",
   new    = new,
   icon   = textures["textures.icons"],
   icon_atlas_pos = vectors.vec2(1,0)
})

--avatar:store("gnui.force_app","system:template")
--avatar:store("gnui.debug",true)
--avatar:store("gnui.force_app",client:getViewer():getUUID()..":template")