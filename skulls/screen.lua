local gnui = require("libraries.gnui")
local http = require("libraries.http")
local tween = require("libraries.GNTweenLib")
local bg = gnui.newSprite():setTexture(textures:newTexture("1x1black",1,1):setPixel(0,0,vectors.vec3(0,0,0))):setUV(1,0)

local httpErrors = {
   [100] = "Continue",
   [101] = "Switching Protocols",
   [102] = "Processing",
   [103] = "Early Hints",
   [200] = "OK",
   [201] = "Created",
   [202] = "Accepted",
   [203] = "Non-Authoritative Information",
   [204] = "No Content",
   [205] = "Reset Content",
   [206] = "Partial Content",
   [207] = "Multi-Status",
   [208] = "Already Reported",
   [226] = "IM Used",
   [300] = "Multiple Choices",
   [301] = "Moved Permanently",
   [302] = "Found",
   [303] = "See Other",
   [304] = "Not Modified",
   [305] = "Use Proxy",
   [307] = "Temporary Redirect",
   [308] = "Permanent Redirect",
   [400] = "Bad Request",
   [401] = "Unauthorized",
   [402] = "Payment Required",
   [403] = "Forbidden",
   [404] = "Not Found",
   [405] = "Method Not Allowed",
   [406] = "Not Acceptable",
   [407] = "Proxy Authentication Required",
   [408] = "Request Timeout",
   [409] = "Conflict",
   [410] = "Gone",
   [411] = "Length Required",
   [412] = "Precondition Failed",
   [413] = "Payload Too Large",
   [414] = "URI Too Long",
   [415] = "Unsupported Media Type",
   [416] = "Range Not Satisfiable",
   [417] = "Expectation Failed",
   [418] = "I'm a teapot",
   [421] = "Misdirected Request",
   [422] = "Unprocessable Entity",
   [423] = "Locked",
   [424] = "Failed Dependency",
   [425] = "Too Early",
   [426] = "Upgrade Required",
   [428] = "Precondition Required",
   [429] = "Too Many Requests",
   [431] = "Request Header Fields Too Large",
   [451] = "Unavailable For Legal Reasons",
   [500] = "Internal Server Error",
   [501] = "Not Implemented",
   [502] = "Bad Gateway",
   [503] = "Service Unavailable",
   [504] = "Gateway Timeout",
   [505] = "HTTP Version Not Supported",
   [506] = "Variant Also Negotiates",
   [507] = "Insufficient Storage",
   [508] = "Loop Detected",
   [510] = "Not Extended",
   [511] = "Network Authentication Required",
}

local errr

local wallpaper_ready = false
local link = "https://raw.githubusercontent.com/lua-gods/Scarlet-Avatar/main/textures/.src/sunset.png"
http.get(link,
function (result, err)
   if err and err ~= 200 then
      errr = err .. " " .. (httpErrors[err] or "")
   else
      textures:read("wallpaper",result)
   end
   wallpaper_ready = true
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
   local screen = gnui.newContainer()

   -- create a screen
   local wallpaper = bg:copy()
   events.FRAME:register(function ()
      if wallpaper_ready then
         
         local err_link = gnui.newLabel():setAlign(0.5,0.6)
         if errr then
            local err_label = gnui.newLabel():setAlign(0.5,0.5)
            err_link:setText({text=link,color="red"}):setFontScale(0.25)
            if not httpErrors[errr] then
               err_label:setText({text="Link Not Allowed",color="red"})
            else
               err_label:setText({text=errr,color="red"})
               err_label:canCaptureCursor(false)
            end
            screen:addChild(err_label:setAnchor(0,0,1,1))
            screen:addChild(err_link:setAnchor(0,0,1,1))
         else
            local dim = textures.wallpaper:getDimensions()
            local r1,r2 = (dim.x / dim.y),(size.x / size.y)
            wallpaper:setTexture(textures.wallpaper):setColor(0,0,0)
            tween.tweenFunction(0,1,3,"inOutCubic",function (value, transition)
               wallpaper:setColor(value,value,value)
            end)
            events.TICK:register(function ()
               local o = (0.2 + (math.sin(client:getSystemTime() / 10000)) * 0.1 * 0.5 + 0.5) * ((r1 - r2) * dim.y)
               wallpaper:setUV(o,0,(dim.x-1) / r1 * r2 + o,dim.y-1)
            end)
         end
         events.FRAME:remove("wallwait")
      end
   end,"wallwait")

   screen:setSprite(wallpaper)
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