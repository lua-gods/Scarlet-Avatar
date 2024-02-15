local lhrot = vec(0,0)
local hrot = vec(0,0)
local hvel = vec(0,0)
local lhvel = vec(0,0)
local hmom = vec(0,0)
local hpos = vec(0,0)
local hpvel = vec(0,0)

local lbrot = 0
local brot = 0
local bvel = 0
local lbvel = 0
local bmom = 0
local bpos = 0
local bpvel = 0

local hhis = {}
local bhis = {}



local config = {
   parts = {
      {group=models.sl.Torso.Hed.hair1,type="front",physics_type="head",intensity=vec(0.25,0,0.5),delay=0},
      {group=models.sl.Torso.Hed.hair2,type="front",physics_type="head",intensity=vec(0.25,0,0.5),delay=1},
      {group=models.sl.Torso.Boby.tie,type="front",intensity=0.5,delay=0},
      {group=models.sl.Torso.Hed.backHair1,type="back",intensity=-0.5,delay=0},
      {group=models.sl.Torso.Hed.backHair1.backHair2,type="back",intensity=-0.5,delay=0},
      {group=models.sl.Torso.Hed.backHair1.backHair2.backHair3,type="back",intensity=-0.5,delay=0},
      --{group=models.sl.Torso.LArm,physics_type="body",type="side",intensity=0.5,delay=0},
      --{group=models.sl.Torso.RArm,physics_type="body",type="side",intensity=-0.5,delay=0},
   },
}

events.TICK:register(function()
   lhrot = hrot * 1
   lhvel = hvel * 1
   hrot = player:getRot()
   hvel = hrot-lhrot
   hmom = hvel-lhvel
   hpvel = hpvel * 0.6 - hpos * 0.1 + hmom
   hpos = hpos + hpvel
   table.insert(hhis,1,hpos * 1)
   if #hhis > 20 then
      table.remove(hhis,20)
   end

   lbrot = brot * 1
   lbvel = bvel * 1
   brot = player:getBodyYaw()
   bvel = brot-lbrot
   bmom = bvel-lbvel

   bpvel = bpvel * 0.8 - bpos * 0.1 + bmom
   bpos = bpos + bpvel
   table.insert(bhis,1,bpos * 1)
   if #bhis > 20 then
      table.remove(bhis,20)
   end
end)



events.RENDER:register(function(dt)
   local trot = math.lerp(lhrot,hrot,dt)
   for key, value in pairs(config.parts) do
      if bhis[value.delay+2] then
         if value.physics_type == "head" then
            local p = math.lerp(hhis[value.delay+2],hhis[value.delay+1],dt)
            if value.type == "top" then
               value.group:setRot(vec(p.x,p.y,0)*value.intensity)
            elseif value.type == "front" then
               value.group:setRot(vec(p.x,0,-p.y)*value.intensity)
            elseif value.type == "side" then
               value.group:setRot(vec(p.x,0,-p.y)*value.intensity)
            end
         else
            local p = math.lerp(bhis[value.delay+2],bhis[value.delay+1],dt)
            if value.type == "side" then
               value.group:setRot(-p*value.intensity,0,0)
            elseif value.type == "back" then
               value.group:setRot(trot.x * 0.3,0,-p*value.intensity)
            else
               value.group:setRot(0,0,-p*value.intensity)
            end
         end
      end
   end
end)

