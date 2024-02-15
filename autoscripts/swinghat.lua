

local model = models.hat.hat.top

local datas = {}

local players = {}

events.TICK:register(function()
   players = world.getPlayers()
   for key, player in pairs(players) do
      local uuid = player:getUUID()
      if not datas[uuid] then
         datas[uuid] = {
         lhrot = vec(0,0),
         hrot  = vec(0,0),
         hvel  = vec(0,0),
         lhvel = vec(0,0),
         hmom  = vec(0,0),
         lhpos = vec(0,0),
         hpos  = vec(0,0),
         hpvel = vec(0,0),
         }
      end
      local d = datas[uuid]
      d.lhrot = d.hrot * 1
      d.lhvel = d.hvel * 1
      d.hrot  = player:getRot()
      d.hvel  = d.hrot-d.lhrot
      d.hmom  = d.hvel-d.lhvel + player:getVelocity().y_ * 15
      d.hpvel = d.hpvel * 0.6 - d.hpos * 0.1 + d.hmom
      d.lhpos = d.hpos
      d.hpos  = d.hpos + d.hpvel
   end
end)



events.SKULL_RENDER:register(function (dt, block, item, entity, ctx)
   if ctx == "HEAD" and entity and datas[entity:getUUID()] then
      local d = datas[entity:getUUID()]
      local p = math.lerp(d.lhpos,d.hpos,dt) --[[@type Vector2]]
      model:setRot(vec(p.x,p.y,0))
   else
      model:setRot(0,0,0)
   end
end)

