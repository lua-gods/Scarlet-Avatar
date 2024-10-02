local eventLib = require "libraries.eventLib"
local tween = require "libraries.GNTweenLib"
local APPS_CHANGED = eventLib.new()
local apps = {}

local GNUI = require "GNUI.main"
local Button = require "GNUI.element.button"

local DEFAULT_APP = "home"

---@class TV.app
---@field TICK eventLib
---@field FRAME eventLib
---@field EXIT eventLib
---@field quit function

---@param rdir Vector3
---@param pdir Vector3
---@param ppos Vector3
---@return Vector3?
local function ray2plane(rpos, rdir, ppos, pdir)
   rdir:normalize()
   pdir:normalize()

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
   local screen = GNUI.newCanvas(false):setScaleFactor(.5)


   local screenBG = GNUI.newNineslice(textures["textures.endesga"],0,0,0,0)
   screen:setNineslice(screenBG)
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
   skull.data.size = size
   
   
   local function quit()
      
   end
   
   local function loadApp(name)
      local background = GNUI.newNineslice(textures["textures.endesga"],0,0,0,0)
      local window = GNUI.newBox(screen):setNineslice(background):setAnchor(0,0,1,1)
      local app = {
         TICK = eventLib.new(),
         FRAME = eventLib.new(),
         EXIT = eventLib.new(),
         quit = quit,
         window = window,
         name = name,
      }
      require("apps."..name)(app,window,screen,skull)
      skull.data.currentApp = app
   end
   
   loadApp(DEFAULT_APP)
   
   -- input processing
   local pressed = false
   events.TICK:register(function ()
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
            screen:setMousePos(pos)
         else
            screen:setMousePos(math.huge,math.huge)
         end
      end
      if client:getViewer():getSwingTime() == 1 then
         if not pressed then pressed = true
            screen:parseInputEvent("key.mouse.left",1)
         end
      end
      if client:getViewer():getSwingTime() == 3 then
         if pressed then pressed = false
            screen:parseInputEvent("key.mouse.left",0)
         end
      end
   end)
end

---@param skull WorldSkull
return function (skull)
   if world.getBlockState(skull.dir + skull.pos).id == "minecraft:emerald_block" then
      return new
   end
end