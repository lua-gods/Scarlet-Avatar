if host:isHost() then return end
local cover = models:newPart("cover"):setParentType("WORLD")
local death = 0
cover:newBlock("cvr"):block("minecraft:redstone_block"):pos(-32,-16,0):scale(4,2,0)
events.WORLD_RENDER:register(function (delta)
   cover:setPos((client:getCameraPos() + client:getCameraDir() * 0.1) * 16):setRot(client:getCameraRot():mul(1,-1,0))
   if player:isLoaded() then
      local offset = client:getCameraPos()-player:getPos()
      
      if offset.y > -1 and offset.y < 1 and offset.xz:length() < 0.5 then
         death = death + 1
         cover:setVisible(true)
      else
         cover:setVisible(false)
      end
   end
end)