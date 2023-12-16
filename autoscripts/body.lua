local last_rel_vel = vectors.vec3()
local rel_vel = vectors.vec3()

local distance_traved = 0
local last_distance_traveled

animations.sl.swing:setSpeed(1.2)
events.TICK:register(function ()
   last_distance_traveled = distance_traved
   last_rel_vel = rel_vel
   rel_vel = player:getVelocity()
   distance_traved = distance_traved + math.min(rel_vel:length(),0.22)
   rel_vel = vectors.rotateAroundAxis(player:getBodyYaw(),rel_vel,vectors.vec3(0,1,0))
   if player:getSwingTime() == 1 then
      animations.sl.swing:stop()
      animations.sl.swing:play()
   end
end)

local rot = vectors.vec2()
local last_rot = vectors.vec2()

local last_sus = 0
local sus = 0
local sus_vel = 0

local was_on_ground = false
local is_on_ground = false

local last_grounded = 0
local grounded = 0

events.TICK:register(function ()
   local acel = vectors.vec3()
   is_on_ground = player:isOnGround()
   if is_on_ground ~= was_on_ground then
      if is_on_ground then
         acel = vectors.vec3(0,last_rel_vel.y*0.5,0)
      end
      was_on_ground = is_on_ground
   end
   last_grounded = grounded
   if is_on_ground then
      grounded = math.min(grounded + .5, 1)
   else
      grounded = math.max(grounded - 0.05, 0)
   end
   last_sus = sus
   sus = sus + sus_vel
   sus_vel = sus_vel * 0.4 + -sus * 0.2
   sus_vel = sus_vel + acel.y * 0.5

   last_rot = rot
   rot = player:getRot():sub(0,player:getBodyYaw())
   rot.y = (rot.y + 180) % 360 - 180
end)

local skirt = models.sl.Legs.Skirt

local verts = skirt:getAllVertices().fabric
local swings = {} ---@type table<any,Vertex>
local swings_ogpos = {} ---@type table<any,Vector3>
for key, value in pairs(verts) do
   local pos = value:getPos()
   if pos.y < 8 then
      swings[key] = value
      swings_ogpos[key] = pos
   end
end

events.RENDER:register(function (delta, context)
   local t = client:getSystemTime() / 1000
   local true_rot = -math.lerp(last_rot,rot,delta)
   local true_distance_traveled = math.lerp(last_distance_traveled,distance_traved,delta)
   local true_rel_vel = math.lerp(last_rel_vel,rel_vel,delta)
   local true_grounded = math.lerp(last_grounded,grounded,delta)
   local sin = math.sin(true_distance_traveled*3)*math.min(math.abs(true_rel_vel.z * 3),1)* true_grounded
   local sin2 = math.sin(true_distance_traveled*6)*math.min(math.abs(true_rel_vel.z * 3),1)* true_grounded
   local cos = math.cos(true_distance_traveled*3)*math.min(math.abs(true_rel_vel.z * 3),1)* true_grounded
   local true_sus = math.lerp(last_sus,sus,delta)
   local duck = math.min(true_sus*16,0)

   local speed = math.clamp(true_rel_vel.z,-0.5,0.5)
   
   local function superSine(value,seed,depth)
      math.randomseed(seed)
      local result = 0
      for i = 1, depth, 1 do
         result = result + math.sin(value * (math.random() * math.pi * depth) + math.random() * math.pi * depth)
      end
      return result / depth
   end

   models.sl:setPos(
      0,
      sin2*0.5+0.5,
      0
   ):setRot(
      true_rel_vel.z * -20,
      0,
      true_rel_vel.x * 20
   )
   models.sl.Torso:setPos(
      0,
      duck,
      -duck - true_rot.x * 0.05
   ):setRot(
      duck*3 + true_rot.x*0.4 + superSine(t,54,2) * 0.2,
      cos * 15 + superSine(t,354,5) * 0.2,
      0
   )
   models.sl.Torso.Hed:setRot(
      true_rot.x*0.6 + superSine(t,123,5) * 0.2,
      true_rot.y + cos * -10 + superSine(t,124,2) * 0.1,
      0
   )
   models.sl.Torso.LArm:setRot(
      sin * -45 + true_rot.x*-0.3 + superSine(t,532,2) * 0.1,
      0,
      math.clamp(math.min(true_rel_vel.y-math.abs(true_rel_vel.z * 0.5),0),-1,0)*90
   )
   models.sl.Torso.RArm:setRot(
      sin * 45 + true_rot.x*-0.3 + superSine(t,426,2) * 0.1,
      0,
      -math.clamp(math.min(true_rel_vel.y-math.abs(true_rel_vel.z * 0.5),0),-1,0)*90
   )
   models.sl.LLeg:setRot(
      duck * 4 + sin * 70 - true_rot.x * 0.2 - speed * 45,
      0,
      0
   ):setPos(
      duck*0.1,
      0,
      duck - true_rot.x * 0.05
   )
   models.sl.RLeg:setRot(
      duck * 4 - sin * 70 - true_rot.x * 0.2 - speed * 45,
      0,
      0
   ):setPos(
      duck*-0.1,
      0,
      duck - true_rot.x * 0.05
   )
   models.sl.Legs:setRot(
      duck * 4 - true_rot.x * 0.2 - speed * 45,
      0,
      0
   ):setPos(
      duck*-0.1,
      0,
      duck - true_rot.x * 0.05
   )
   local mat = matrices.mat4()
   mat:scale(1,1,1+math.abs(sin)*1.6)
   mat.c1 = vectors.vec4(mat.c1.x,mat.c1.y,sin,mat.c1.w)
   for i, value in pairs(swings) do
      value:setPos(mat:apply(swings_ogpos[i]))
   end
end)

local was_sitting = false
events.TICK:register(function ()
   animations.sl.sneak:blend(player:getPose() == "CROUCHING" and 1 or 0)
   local sitting = player:getVehicle() and true
   if was_sitting ~= sitting then
      if sitting then
         animations.sl.sit:play()
      else
         animations.sl.sit:stop()
      end
      was_sitting = sitting
   end
end)

animations.sl.sneak:play()