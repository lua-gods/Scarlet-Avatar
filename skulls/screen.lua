local gnui = require("libraries.gnui")
local http = require("libraries.http")
local tween = require("libraries.GNTweenLib")
local bg = gnui.newSprite():setTexture(textures:newTexture("1x1black",1,1):setPixel(0,0,vectors.vec3(0,0,0))):setUV(1,0)

local wallpaper_ready = false
http.get("https://media.discordapp.net/attachments/1124181688566681701/1191341307340259379/2024-01-01_19.18.55.png",
function (result, err)
   if not err then
      textures:read("wallpaper",result)
      wallpaper_ready = true
   end
end,"base64")

---@param ray_dir Vector3
---@param plane_dir Vector3
---@param plane_pos Vector3
---@return Vector3?
local function ray2plane(ray_pos, ray_dir, plane_pos, plane_dir)
   ray_dir = ray_dir:normalize()
   plane_dir = plane_dir:normalize()

   local dot = ray_dir:dot(plane_dir)
   if dot < 1e-6 then return nil end

   local t = (plane_pos - ray_pos):dot(plane_dir) / dot
   if t < 0 then return nil end

   local intersection = ray_pos + ray_dir * t
   return intersection
end

---@param pos Vector3
---@param block Minecraft.blockID
local function check(pos,block)
   return world.getBlockState(pos).id == block
end

---@param skull WorldSkull
---@param events SkullEvents
local function new(skull,events)
   local mat = matrices.mat4()
   mat
   :rotateY(skull.rot)
   :translate(skull.pos)
   :translate(-skull.dir)

   local lmat = mat:copy():invert()

   -- get screen size
   local b = world.getBlockState(mat:apply(0,0,0)).id
   local r = vectors.vec4()
   for i = 1, 100, 1 do if not check(mat:apply(i,0,0),b) then break end r.x = r.x + 1 end
   for i = 1, 100, 1 do if not check(mat:apply(-i,0,0),b) then break end r.z = r.z + 1 end
   for i = 1, 100, 1 do if not check(mat:apply(0,i,0),b) then break end r.y = r.y + 1 end
   for i = 1, 100, 1 do if not check(mat:apply(0,-i,0),b) then break end r.w = r.w + 1 end

   local size = vectors.vec2(r.x+r.z+1,r.y+r.w+1)

   -- create a screen
   local wallpaper = bg:copy()
   events.FRAME:register(function ()
      if wallpaper_ready then
         wallpaper:setTexture(textures.wallpaper):setColor(0,0,0)

         local dim = textures.wallpaper:getDimensions()
         local r1,r2 = (dim.x / dim.y),(size.x / size.y)
         tween.tweenFunction(0,1,3,"inOutCubic",function (value, transition)
            wallpaper:setColor(value,value,value)
         end)
         events.TICK:register(function ()
            local o = (0.2 + (math.sin(client:getSystemTime() / 10000)) * 0.1 * 0.5 + 0.5) * ((r1 - r2) * dim.y)
            wallpaper:setUV(o,0,(dim.x-1) / r1 * r2 + o,dim.y-1)
         end)
         events.FRAME:remove("wallwait")
      end
   end,"wallwait")

   
   local screen = gnui.newContainer():setSprite(wallpaper)
   skull.model_block
   :newPart("screen")
   :pos((-skull.dir * 1.51 + vectors.vec3(0.5,0.5,0.5)) * 16)
   :rot(0,skull.rot + 180)
   :addChild(screen.Part)
   
   screen:setDimensions(
      -r.z * 16 - 8,
      -r.y * 16 - 8,
      r.x * 16 + 8,
      r.w * 16 + 8
   )
   -- input processing
   events.FRAME:register(function ()
      local p = ray2plane(
         client:getCameraPos(),
         client:getCameraDir(),
         skull.pos:copy():add(0.5,0.5,0.5) - skull.dir * 1.5,
         skull.dir
      )
      if p then
         local lp = lmat:apply(p + vectors.vec3(0,0.5,0) + (vectors.rotateAroundAxis(90,skull.dir,vectors.vec3(0,1,0)) * -0.5 - 0.5))
         if lp.y > -r.w and lp.y-1 < r.y
         and lp.x > -r.z and lp.x-1 < r.x
         then
            screen:setCursor(
               math.map(lp.x,-r.z,r.x+1,0,size.x * 16),
               math.map(lp.y,-r.w,r.y+1,size.y * 16,0)
            )
            --particles.end_rod:pos(p):lifetime(0):spawn():scale(1)
         end
      end
      
   end)
   -- W
   local label = gnui.newLabel()
   label:canCaptureCursor(false)
      label:setFontScale(4)
      :setText({text="W"})
      :setAnchor(0,0,1,1)
      screen:addChild(label)
   events.FRAME:register(function ()
      local time = client:getSystemTime() / 5000
      label:setAlign(math.abs(time % 2 - 1) ,math.abs(time * 0.99 % 2 - 1))
   end)
end

---@param skull WorldSkull
return function (skull)
   if world.getBlockState(skull.dir + skull.pos).id == "minecraft:emerald_block" then
      return new
   end
end