local eventLib = require "libraries.eventLib"
local tween = require "libraries.GNTweenLib"
local APPS_CHANGED = eventLib.new()
local apps = {}

local GNUI = require "GNUI.main"
local Button = require "GNUI.primitives.box"

local DEFAULT_APP = "system:home"


---@class TV.app
---@field TICK eventLib
---@field FRAME eventLib
---@field EXIT eventLib
---@field exit function
---@field restart function

---@param rdir Vector3
---@param pdir Vector3
---@param ppos Vector3
---@return Vector3?
local function ray2plane(rpos, rdir, ppos, pdir)
   rdir = rdir:normalize()
   pdir = pdir:normalize()

   local dot = rdir:dot(pdir)
   if dot < 1e-6 then return nil end

   local t = (ppos - rpos):dot(pdir) / dot
   if t < 0 then return nil end

   local intersection = rpos + rdir * t
   return intersection
end



---@param pos Vector3
---@param block Minecraft.blockID
local function isBlock(pos,block)
   return world.getBlockState(pos).id == block
end

---@param skull WorldSkull
---@param events TV.app
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
   for i = 1, 100, 1 do if not isBlock(mat:apply(i,0,0),b) then break end r.x = r.x + 1 end
   for i = 1, 100, 1 do if not isBlock(mat:apply(-i,0,0),b) then break end r.z = r.z + 1 end
   for i = 1, 100, 1 do if not isBlock(mat:apply(0,i,0),b) then break end r.y = r.y + 1 end
   for i = 1, 100, 1 do if not isBlock(mat:apply(0,-i,0),b) then break end r.w = r.w + 1 end

   local size = vectors.vec2(r.x+r.z+1,r.y+r.w+1)
   local screen = GNUI.newCanvas(false):setScaleFactor(1)

   local function invokeError(err)
      local label = GNUI.newBox(skull.data.current_app_screen):setTextBehavior("WRAP")
      label:setText({text=err,color="red"})
      --label:setFontScale(0.5)
      label:setBlockMouse(false):setAnchor(0,0,1,1)
      --local leave = gnui.newLabel():setText("[Exit]"):setDimensions(-28,-10,0,0)
      --leave.PRESSED:register(function ()
      --   skull.data.setApp(DEFAULT_APP)
      --end)
      --leave:setAnchor(1,1)
      --skull.data.current_app_screen:addChild(leave)
   end

   local app_changed
   skull.data.APPS_CHANGED = eventLib.new()

   local exit = function ()
      skull.data.setApp(DEFAULT_APP)
   end

   local restart = function ()
      skull.data.setApp(skull.data.current_app_id)
   end

   local gizmo = GNUI.newBox(screen)
   
   GNUI.newBox(screen):setDimensions(16,16,64,64)
   
   function skull.data.setApp(id)
      if id then
         local is_same_app = id == skull.data.current_app_id
         if skull.data.current_app_screen then
            local death_screen = skull.data.current_app_screen
            if not is_same_app then
               local death_id = skull.data.current_app_id
               tween.tweenFunction(1,0,0.5,"inOutQuart",function (t)
                  if death_id ~= DEFAULT_APP then
                     death_screen:setAnchor(math.lerp(skull.data.transition_origin_anchor or vectors.vec4(.5,.5,.5,.5),vectors.vec4(0,0,1,1),t))
                     death_screen:setDimensions(math.lerp(skull.data.transition_origin_dim or vectors.vec4(),vectors.vec4(0,0,0,0),t))
                     death_screen:setScaleFactor(1):setZMul(4)
                  end
               end,function ()
                  local ok, err = pcall(skull.data.current_app_events.EXIT.invoke,skull.data.current_app_events.EXIT)
                  if not ok then invokeError(err) end
                  screen:removeChild(death_screen)
               end)
            else
               skull.data.current_app_events.EXIT:invoke()
               screen:removeChild(death_screen)
            end
         end
         
         ---@type TV.app
         local app_event = {
            TICK  = eventLib.new(),
            FRAME = eventLib.new(),
            EXIT  = eventLib.new(),
            exit = exit,
            restart = restart,
         }
         skull.data.current_app_id = id
         math.randomseed(client:getSystemTime())
         local blank_sprite = GNUI.newNineslice(textures["textures.endesga"],0,0,0,0):setRenderType("EMISSIVE_SOLID")
         local app_screen = GNUI.newBox(screen):setNineslice(blank_sprite):setAnchor(0,0,1,1)
         if not is_same_app then
            tween.tweenFunction(0,1,0.5,"inOutQuart",function (t)
               if id ~= DEFAULT_APP then
                  app_screen:setAnchor(math.lerp(skull.data.transition_origin_anchor or vectors.vec4(.5,.5,.5,.5),vectors.vec4(0,0,1,1),t))
                  app_screen:setDimensions(math.lerp(skull.data.transition_origin_dim or vectors.vec4(),vectors.vec4(0,0,0,0),t))
                  app_screen:setScaleFactor(1):setZMul(4)
               end
            end,function ()
               app_screen:setZMul(1)
               app_screen:setScaleFactor(1)
            end)
         else
            app_screen:setAnchor(0,0,1,1)
            app_screen:setDimensions(0,0,0,0)
         end
         skull.data.current_app_events = app_event
         skull.data.current_app_screen = app_screen
         screen:addChild(app_screen)
         local ok, err = pcall(apps[id].new,GNUI,app_screen,app_event,skull)
         skull.data.current_app = err
         if not ok then invokeError(err) end
      end
   end

   local screen_sprite = GNUI.newNineslice(textures["textures.endesga"],0.1,0.1,0.1,0.1):setRenderType("EMISSIVE_SOLID")
   screen:setNineslice(screen_sprite)
   skull.model_block
   :newPart("screen")
   :pos((-skull.dir * 1.51 + vectors.vec3(0.5,0.5,0.5)) * 16)
   :rot(0,skull.rot + 180)
   :addChild(screen.ModelPart)
   
   
   
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
         local ok, err = pcall(skull.data.current_app_events.TICK.invoke,skull.data.current_app_events.TICK)
         if not ok then invokeError(err) end
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
            local pos = vec(
            math.map(lp.x,-r.z,r.x+1,0,size.x)*16,
            math.map(lp.y,-r.w,r.y+1,size.y,0)*16
         )
         gizmo:setDimensions(pos.x,pos.y,pos.x+5,pos.y+5):setAnchor(0.5,0.5)
            screen:setMousePos(pos)
         else
            screen:setMousePos(math.huge,math.huge)
         end
      end
      local pressed = false
      if client:getViewer():getSwingTime() == 1 then
         if not pressed then
            pressed = true
            screen:parseInputEvent("key.mouse.left",true)
         end
      else
         if pressed then
            pressed = false
            screen:parseInputEvent("key.mouse.left",false)
         end
      end
   end)

   events.FRAME:register(function (dt,df)
      if skull.data.current_app_events then
         local ok, err = pcall(skull.data.current_app_events.FRAME.invoke,skull.data.current_app_events.FRAME,dt,df)
         if not ok then invokeError(err) end
      end
   end)
   events.EXIT:register(function ()
      skull.data.startup = false
      if skull.data.current_app_events then
         pcall(skull.data.current_app_events.EXIT.invoke,skull.data.current_app_events.EXIT)
      end
   end)
   skull.data.startup = true
   app_changed = function ()
      skull.data.apps = apps
      local default = DEFAULT_APP
      local meta = world.avatarVars()[client:getViewer():getUUID()]
      if meta and meta["gnui.force_app"] then
         default = meta["gnui.force_app"]
      end
      if skull.data.startup and apps[default] then
         skull.data.setApp(default)
         skull.data.startup = false
      end
      skull.data.APPS_CHANGED:invoke()
      if skull.data.current_app_id ~= DEFAULT_APP then
         skull.data.setApp(skull.data.current_app_id)
      end
   end
   APPS_CHANGED:register(app_changed)
   app_changed()
end

local function reloadApps()
   apps = {}
   for uuid, vars in pairs(world.avatarVars()) do
      for key, data in pairs(vars) do
         if key:match("^gnui%.app%..") then
            local id = (uuid == avatar:getUUID() and 'system' or uuid) .. ':' .. data.name:lower()
            apps[id] = {
               id = id,
               update = data.update,
               name   = data.name,
               new    = data.new,
               icon   = data.icon,
               icon_atlas_pos   = data.icon_atlas_pos,
            }
            --print("new app: " .. id)
         end
      end
   end
end

local app_check_timer = 0
events.WORLD_TICK:register(function ()
   app_check_timer = app_check_timer + 1
   if app_check_timer > 10 then
      local update = false
      app_check_timer = 0
      for uuid, vars in pairs(world.avatarVars()) do
         for key, data in pairs(vars) do
            if key:match("^gnui%.app%..") then
               local id = (uuid == avatar:getUUID() and 'system' or uuid) .. ':' .. data.name:lower()
               if not apps[id] or (apps[id] and apps[id].update ~= data.update) then
                  update = true
               end
            end
         end
      end
      if update then
         reloadApps()
         APPS_CHANGED:invoke()
      end
   end
end)


---@param skull WorldSkull
return function (skull)
   if world.getBlockState(skull.dir + skull.pos).id == "minecraft:emerald_block" then
      return new
   end
end