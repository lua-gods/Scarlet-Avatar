local model = models.skulls.door
local tween = require("libraries.GNTweenLib")
model:setVisible(false)
model:setPrimaryRenderType("TRANSLUCENT_CULL")
model:setLight(10,0)

local offset = vectors.vec3(0,-4,0)
local other = vectors.vec3(0,0,-32)


local players = {} --[[@type Player[] ]]
events.WORLD_TICK:register(function ()
   players = world.getPlayers()
end)

---@param skull WorldSkull
---@param events SkullEvents
local function new(skull,events)
   skull.model:addChild(model:copy("door"):pos(offset * 16):setVisible(true))
   skull.model:addChild(model:copy("door2"):pos(offset * 16 + other):setVisible(true))
   skull.data.open = false
   
   local invmat = matrices.mat4()
   invmat:rotateY(skull.rot)
   invmat:translate(skull.pos + vectors.vec3(0.5,0.5,0.5) - skull.dir * 0.5)
   invmat:invert()


   events.TICK:register(function ()
      local open = false
      for key, player in pairs(players) do
         local ppos = player:getPos() - offset
         local o = ppos - skull.pos
         if math.abs(o.x) + math.abs(o.y) + math.abs(o.z) < 10 then -- close enough
            local pos = invmat:apply(ppos)
            if math.abs(pos.x) < 2 and pos.z < 0 and pos.z > -4 and pos.y > -1 and pos.y < 7 then
               open = true
               break
            end
         end
      end
      if open ~= skull.data.open then
         skull.data.open = open
         
         if open then
            sounds:playSound("minecraft:block.candle.extinguish",skull.pos,0.5,1)
            tween.tweenFunction(skull.data.t,1,0.5,"outCubic",function (y)
               skull.model.door:pos(offset * 16 + vectors.vec3(0,0,y*2*15.9))
               skull.model.door2:pos(offset * 16 + other - vectors.vec3(0,0,y*2*15.9))
               skull.data.t = y
            end,nil,"door"..skull.i)
         else
            tween.tweenFunction(skull.data.t,0,0.5,"inCubic",function (y)
               skull.model.door:pos(offset * 16 + vectors.vec3(0,0,y*2*15.9))
               skull.model.door2:pos(offset * 16 + other - vectors.vec3(0,0,y*2*15.9))
               skull.data.t = y
            end,function ()
               sounds:playSound("minecraft:block.note_block.bass",skull.pos,0.5,0.2)
               sounds:playSound("minecraft:block.stone.place",skull.pos,0.5,0.5)
            end,"door"..skull.i)
         end
      end
   end)
end

---@param skull WorldSkull
return function (skull)
   if skull.is_wall and world.getBlockState(skull.pos:copy():sub(skull.dir)).id == "minecraft:spruce_wood" then
      return new
   end
end