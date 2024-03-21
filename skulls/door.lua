local tween = require("libraries.GNTweenLib")

local players = {} --[[@type Player[] ]]
events.WORLD_TICK:register(function ()
   players = world.getPlayers()
end)

---@param skull WorldSkull
---@param events SkullEvents
---@param all_skulls WorldSkull[]
local function new(skull,events,all_skulls)
   local door = skull.model_block:newPart("door"):pos(8,0,8):rot(0,skull.rot + 180,0)
   local size = vectors.vec2(0,0)
   local true_width = 0

   -- get width
   for i = 1, 20, 1 do
      local pos = skull.pos:copy():add(0,2,0):add(skull.dir * i)
      local b = world.getBlockState(pos).id
      if b ~= "minecraft:air" then 
         
         break
      end
      size.x = size.x + 1
   end
   -- get height from the middle of the door
   for i = 2, 10, 1 do 
      local b = world.getBlockState(skull.pos:copy():add(0,i,0):add(skull.dir * size.x / 2))
      if b.id ~= "minecraft:air" then 
         if not b:isFullCube() then
            size.y = size.y + 1
         end
         break
      end
      size.y = size.y + 1
   end

   local half = false
   local b = world.getBlockState(skull.pos:copy():add(skull.dir*size.x)).id
   if b:find("^minecraft:player.+head$") then
      half = true
   end
   true_width = size.x
   if half then
      size.x = ((size.x+1) / 2) - 1
   end
   local is_odd = (true_width/2) % 2 == 1
   local i = 0
   for y = 0, size.y, 1 do
      for x = 0, math.ceil(size.x), 1 do
         i = i + 1
         local pane = door:newBlock("block"..i):block("minecraft:white_stained_glass_pane[north=true,south=true]"):pos(-8,y * 16 + 16,x * 16 - 8)
         if is_odd and x == math.ceil(size.x) then
            pane:block("minecraft:white_stained_glass_pane[north=true]")
         end
      end
   end

   skull.data.open = false

   local invmat = matrices.mat4()
   invmat:rotateY(skull.rot)
   invmat:translate(skull.pos + vectors.vec3(0.5,0.5,0.5) - skull.dir * 0.5)
   invmat:invert()
   events.TICK:register(function ()
      local open = false
      for key, player in pairs(players) do
         local ppos = player:getPos()
         local o = ppos - skull.pos
         if math.abs(o.x) + math.abs(o.y) + math.abs(o.z) < 10 then -- close enough
            local pos = invmat:apply(ppos)
            if math.abs(pos.x) < 2
            and pos.z < 0 and pos.z > -true_width-1
            and pos.y > 0 and pos.y < size.y+1 then
               open = true
               break
            end
         end
      end
      if open ~= skull.data.open then
         skull.data.open = open
         if open then
            sounds:playSound("minecraft:block.candle.extinguish",skull.pos,0.5,1)
            tween.tweenFunction(skull.data.t,1,0.1*true_width,"linear",function (y)
               skull.model_block.door:pos(vectors.vec3(8,0,8) - skull.dir * y * (size.x + 1) * 15.9)
               skull.data.t = y
            end,function ()
               --sounds:playSound("minecraft:block.note_block.bass",skull.pos,0.5,0.2)
               --sounds:playSound("minecraft:block.stone.place",skull.pos,0.5,0.5)
            end,"door"..skull.i)
         else
            sounds:playSound("minecraft:block.candle.extinguish",skull.pos,0.5,1)
            tween.tweenFunction(skull.data.t,0,0.1*true_width,"linear",function (y)
               skull.model_block.door:pos(vectors.vec3(8,0,8) - skull.dir * y * (size.x + 1) * 15.9)
               skull.data.t = y
            end,function ()
               sounds:playSound("minecraft:block.note_block.bass",skull.pos,1,0.2)
               --sounds:playSound("minecraft:block.stone.place",skull.pos,0.5,0.5)
            end,"door"..skull.i)
         end
      end
   end)
end

---@param skull WorldSkull
return function (skull)
   local b = world.getBlockState(skull.pos:copy():add(0,1,0)).id
   if skull.is_wall and b:find("minecraft:.+_carpet") then
      return new
   end
end