local config = {
   fastest_wait = 1*20,
   longest_wait = 3*20,

   stare_fast = 0.5*20,
   stare_long = 1*20,
}

vanilla_model.HEAD:setVisible(false)

local blink_time = 0
local look = vec(0,0)

local stare_time = 0
local stare_at = nil
local can_look_at = {}
events.TICK:register(function()
   if stare_time >= 0 then
      stare_time = stare_time + 1
   end
   --math.randomseed(world.getTimeOfDay())
   if stare_time > 1 then
      stare_at = nil
      stare_time = -1
      can_look_at = {}
      for i, p in pairs(world.getPlayers()) do
         local eye_pos = p:getPos()+vec(0,p:getEyeHeight(),0)
         local mat = matrices.mat4()
         local head_rot = player:getRot()
         mat:rotate(head_rot.x,-head_rot.y,0)
         mat:invert()
         local spos = p:getPos()+vec(0,p:getEyeHeight(),0)
         local cpos = player:getPos()+vec(0,player:getEyeHeight(),0)
         spos = spos - cpos
         spos = (mat * vec(spos.x,spos.y,spos.z,1)).xyz
         spos = vec(spos.x,-spos.y,spos.z)
         if spos.z > 0 and math.abs(spos.x / spos.z) < 0.9 and math.abs(spos.y / spos.z) < 0.8 and p:getName() ~= player:getName() then
            table.insert(can_look_at,p)
         end
      end
      if #can_look_at > 0 then
         stare_at = can_look_at[math.random(1,#can_look_at)]
      end
   end
   
   if stare_at and stare_at:isLoaded() then
      local mat = matrices.mat4()
      local head_rot = player:getRot()
      mat:rotate(head_rot.x,-head_rot.y,0)
      mat:invert()
      local spos = stare_at:getPos()+vec(0,stare_at:getEyeHeight(),0)
      local cpos = player:getPos()+vec(0,player:getEyeHeight(),0)
      spos = spos - cpos
      spos = (mat * vec(spos.x,spos.y,spos.z,1)).xyz
      spos = vec(spos.x,-spos.y,spos.z)
      look = vec(math.clamp(spos.x / -spos.z,-1,1),math.clamp(spos.y / -spos.z,-1,1))
   else
      look = vec(
   ((player:getRot().y-player:getBodyYaw() + 90 ) % 180 - 90)/90,
   (player:getRot().x)/-90
   )
   end
   blink_time = blink_time - 1
   math.randomseed(math.random())
   if blink_time < 0 then
      blink_time = math.lerp(config.fastest_wait,config.longest_wait,math.random())
      animations.sl.blink:play()
      stare_time = 0
   end
   models.sl.Torso.Hed.eyes.lpupil:setPos(math.clamp(look.x,0,1),0,0)
   models.sl.Torso.Hed.eyes.rpupil:setPos(math.clamp(look.x,-1,0),0,0)
   models.sl.Torso.Hed.eyes.lpupil:setUV(0,look.y/128)
   models.sl.Torso.Hed.eyes.rpupil:setUV(0,look.y/128)
end)