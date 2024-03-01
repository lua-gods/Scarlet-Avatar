local gnui = require("libraries.gnui")
local eventLib = require("libraries.eventLib")

local APPS_CHANGED = eventLib.new()
local apps = {}

---@class GNUI.TV.app
---@field TICK EventLib
---@field FRAME EventLib
---@field EXIT EventLib

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
   local screen = gnui.newContainer()

   skull.data.apps = apps
   skull.data.APPS_CHANGED = eventLib.new()
   function skull.data.setApp(id)
      if id then
         if skull.data.current_screen then
            skull.data.current_app_events.EXIT:invoke()
            screen:removeChild(skull.data.current_screen)
         end
         ---@type GNUI.TV.app
         local app_event = {
            TICK  = eventLib.new(),
            FRAME = eventLib.new(),
            EXIT  = eventLib.new()
         }
         skull.data.current_app_id = id
         math.randomseed(client:getSystemTime())
         local blank_sprite = gnui.newSprite():setTexture(textures["textures.endesga"]):setUV(0,0):setRenderType("EMISSIVE_SOLID")
         local app_screen = gnui.newContainer():setSprite(blank_sprite):setAnchor(0,0,1,1)
         skull.data.current_app = apps[id].new(gnui,app_screen,app_event,skull)
         skull.data.current_app_events = app_event
         skull.data.current_screen = app_screen
         screen:addChild(app_screen)
      end
   end

   local screen_sprite = gnui.newSprite():setTexture(textures["textures.endesga"]):setUV(0,0)
   screen:setSprite(screen_sprite)
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
   skull.data.tv_size = size
   -- input processing
   events.TICK:register(function ()
      if skull.data.current_app_events then
         skull.data.current_app_events.TICK:invoke()
      end
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
         end
      end
      if client:getViewer():getSwingTime() == 1 then
         screen:setCursor(true)
      end
   end)

   events.FRAME:register(function (dt,df)
      if skull.data.current_app_events then
         skull.data.current_app_events.FRAME:invoke(dt,df)
      end
   end)
   events.EXIT:register(function ()
      skull.data.startup = false
      if skull.data.current_app_events then
         skull.data.current_app_events.EXIT:invoke()
      end
   end)

   skull.data.startup = true
   local function startup()
      local default = "system:home"
      local meta = world.avatarVars()[client:getViewer():getUUID()]
      if meta and meta["gnui.force_app"] then
         default = meta["gnui.force_app"]
      end
      if skull.data.startup and apps[default] then
         skull.data.setApp(default)
         skull.data.startup = false
      end
      skull.data.APPS_CHANGED:invoke()
   end
   startup()
   APPS_CHANGED:register(startup)
end


local app_check_timer = 0
events.WORLD_TICK:register(function ()
   app_check_timer = app_check_timer + 1
   if app_check_timer > 10 then
      app_check_timer = 0
      for uuid, vars in pairs(world.avatarVars()) do
         for key, data in pairs(vars) do
            if key:match("^gnui%.app%..") then
               local id = (uuid == avatar:getUUID() and 'system' or uuid) .. ':' .. data.name:lower()
               if not apps[id] or (apps[id] and apps[id].update ~= data.update) then
                  --register app
                  apps[id] = {
                     id = id,
                     update = data.update,
                     name   = data.name,
                     new    = data.new,
                     icon   = data.icon,
                     icon_atlas_pos   = data.icon_atlas_pos,
                  }
                  --print("new app: " .. id)
                  APPS_CHANGED:invoke()
               end
            end
         end
      end
   end
end)


---@param skull WorldSkull
return function (skull)
   if world.getBlockState(skull.dir + skull.pos).id == "minecraft:emerald_block" then
      return new
   end
end