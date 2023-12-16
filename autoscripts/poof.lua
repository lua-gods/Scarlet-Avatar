
local colors = {
   vectors.hexToRGB("#f68187"),
   vectors.hexToRGB("#f5555d"),
   vectors.hexToRGB("#ea323c"),
   vectors.hexToRGB("#c42430"),
   vectors.hexToRGB("#891e2b"),
   vectors.hexToRGB("#571c27"),
}

function pings.GNPOOF(x,y,z)
   local pos = vectors.vec3(x,y,z)
   particles:newParticle("minecraft:flash",pos):setColor(colors[2])
   for i = 1, 200, 1 do
      local v = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*math.random()*0.5
      particles:newParticle("minecraft:end_rod",pos):setVelocity(v):color(colors[math.random(1,#colors)])
   end
   --sounds:playSound("minecraft:entity.allay.item_thrown",pos,1,1.2)
   sounds:playSound("minecraft:entity.firework_rocket.blast",pos,1,1)
end

if not host:isHost() then return end

local last_gamemode = nil

events.TICK:register(function ()
   local gamemode = player:getGamemode()
   if last_gamemode and last_gamemode ~= gamemode and (gamemode == "SPECTATOR" or last_gamemode == "SPECTATOR") then
      local pos = player:getPos():add(0,1,0)
      pings.GNPOOF(pos.x,pos.y,pos.z)
   end
   last_gamemode = gamemode
end)