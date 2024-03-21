local http = require("libraries.http")
local tween = require("libraries.GNTweenLib")
local eventlib = require("libraries.eventLib")

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

--local errr
--local wallpaper_ready = false
--local link = "https://raw.githubusercontent.com/lua-gods/Scarlet-Avatar/main/textures/.src/vector_forest.png"
--http.get(link,
--function (result, err)
--   if err then
--      errr = err .. " " .. (httpErrors[err] or "")
--   else
--      textures:read("wallpaper",result)
--   end
--   wallpaper_ready = true
--end,"base64")

---@param gnui GNUI
---@param events GNUI.TV.app
---@param screen GNUI.container
---@param skull WorldSkull
local function new(gnui,screen,events,skull)
   local size = skull.data.tv_size
   local row_count = math.floor(((size.x * 16) / 24))
   events.TICK:register(function ()
   end)

   local wallpaper = gnui.newSprite():setRenderType("EMISSIVE_SOLID")
   wallpaper:setTexture(textures["textures.firewatch_pixelated"])
   screen:setSprite(wallpaper)
   --events.FRAME:register(function ()
   --   if wallpaper_ready then
   --      screen:setSprite(wallpaper)
   --      
   --      local err_link = gnui.newLabel():setAlign(0.5,0.6):canCaptureCursor(false)
   --      if errr then
   --         local err_label = gnui.newLabel():setAlign(0.5,0.5):canCaptureCursor(false)
   --         err_link:setText({text=link,color="red"}):setFontScale(0.25)
   --         if not httpErrors[errr] then
   --            err_label:setText({text="Link Not Allowed",color="red"})
   --         else
   --            err_label:setText({text=errr,color="red"})
   --            err_label:canCaptureCursor(false)
   --         end
   --         screen:addChild(err_label:setAnchor(0,0,1,1))
   --         screen:addChild(err_link:setAnchor(0,0,1,1))
   --      else
   --         local dim = textures.wallpaper:getDimensions()
   --         local r1,r2 = (dim.x / dim.y),
   --         (size.x / size.y)
   --         wallpaper:setTexture(textures.wallpaper):setColor(0,0,0)
   --         tween.tweenFunction(0,1,1.5,"inOutCubic",function (value, transition)
   --            wallpaper:setColor(value,value,value)
   --         end)
   --         events.TICK:register(function ()
   --            local o = (0.2 + (math.sin(client:getSystemTime() / 10000)) * 0.1 * 0.5 + 0.5) * ((r1 - r2) * dim.y)
   --            wallpaper:setUV(o,0,(dim.x-1) / r1 * r2 + o,dim.y-1)
   --         end)
   --      end
   --      events.FRAME:remove("wallwait")
   --   end
   --end,"wallwait")

   local app_list
   local function updateList()
      if app_list then
         screen:removeChild(app_list)
      end
      app_list = gnui.newContainer()
      app_list:setAnchor(0,0,1,1)
      -- school massacre
      local i = 0
      for key, app in pairs(skull.data.apps) do
         local icontainer = gnui.newContainer()
         local spritecon = gnui.newSprite()
         spritecon:setTexture(app.icon)
         if app.icon_atlas_pos then
            spritecon:setUV(
               app.icon_atlas_pos.x*10,
               app.icon_atlas_pos.y*10,
               app.icon_atlas_pos.x*10+9,
               app.icon_atlas_pos.y*10+9)
         end

         local icon = gnui.newContainer()
         icon:setSprite(spritecon)
         icon:setAnchor(0.2,0.2,0.8,0.8)
         icon:setCanCaptureCursor(false)
         icontainer:addChild(icon)

         local name = gnui.newLabel()
         name:setText({text=app.name,color="#2e112d"})
         name:setAlign(0.5,0)
         name:setAnchor(0,1,1,1)
         name:setDimensions(0,-4,0,4)
         name:setFontScale(math.min(1/client.getTextWidth(app.name) * 24,0.4))
         name:setTextEffect("NONE")
         name:setCanCaptureCursor(false)

         local pos = vectors.vec2(i % row_count,math.floor(i / row_count))
         icontainer:setDimensions(pos.x * 24,pos.y * 24,(pos.x+1) * 24,(pos.y+1) * 24)
         i = i + 1
         icontainer:addChild(name)
         app_list:addChild(icontainer)
         icontainer.PRESSED:register(function ()
            skull.data.transition_origin_dim = icontainer.Dimensions:copy():add(4,4,-4,-4)
            skull.data.transition_origin_anchor = vectors.vec4()
            skull.data.setApp(app.id)
         end)
      end
      screen:addChild(app_list)
   end
   updateList()
   skull.data.APPS_CHANGED:register(updateList,skull.id)
   events.EXIT:register(function ()
      skull.data.APPS_CHANGED:remove(skull.id)
   end)

   local clockLabel = gnui.newLabel()
   clockLabel:setText('time'):setCanCaptureCursor(false)
   clockLabel:setAlign(1, 1):setAnchor(0.5, 0.5, 1, 1):setDimensions(-4, -14)
   clockLabel:setFontScale(2)
   screen:addChild(clockLabel)
   local dateLabel = gnui.newLabel()
   dateLabel:setText('date'):setCanCaptureCursor(false)
   dateLabel:setAlign(1, 1):setAnchor(1, 1, 1, 1):setDimensions(-1000, -20,0,0)
   screen:addChild(dateLabel)
   events.TICK:register(function()
      local date = client.getDate()
      clockLabel:setText(date.hour .. ':' .. string.format('%02d', date.minute))
      dateLabel:setText(date.day_name .. ' ' .. date.day .. ' ' .. date.month_name .. ' ' .. date.year)
   end)

end

avatar:store("gnui.app.home",{
   update = client:getSystemTime(),
   name   = "Home",
   new    = new,
   icon   = textures["textures.icons"],
   icon_atlas_pos = vectors.vec2(1,0)
})