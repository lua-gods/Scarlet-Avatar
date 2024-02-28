local gnui = require("libraries.gnui")
local http = require("libraries.http")
local tween = require("libraries.GNTweenLib")
local eventlib = require("libraries.eventLib")
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
   if err then
      errr = err .. " " .. (httpErrors[err] or "")
   else
      textures:read("wallpaper",result)
   end
   wallpaper_ready = true
end,"base64")

---@param events GNUI.TV.app
---@param screen GNUI.container
---@return GNUI.TV.app
local function new(events,screen,skull)
   local size = skull.data.tv_size

   local wallpaper = bg:copy():setRenderType("EMISSIVE_SOLID")
   events.FRAME:register(function ()
      if wallpaper_ready then
         screen:setSprite(wallpaper)
         
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
         local sp = gnui.newSprite()
         sp:setTexture(app.icon)

         local icon = gnui.newContainer()
         icon:setSprite(sp)
         icon:setAnchor(0.25,0.25,0.75,0.75)
         icon:canCaptureCursor(false)
         icontainer:addChild(icon)

         local name = gnui.newLabel()
         name:setText(app.name)
         name:setAlign(0.5,0)
         name:setAnchor(0,1,1,1)
         name:setDimensions(-100,-8,100,0)
         name:setFontScale(0.5)
         name:setTextEffect("OUTLINE")
         name:canCaptureCursor(false)

         icontainer:setDimensions(i* 32,0,32+i* 32,32)
         i = i + 1
         icontainer:addChild(name)
         app_list:addChild(icontainer)
         icontainer.PRESSED:register(function ()
            skull.data.setApp(app.id)
         end)
      end
      screen:addChild(app_list)
   end
   updateList()
   skull.data.APPS_CHANGED:register(updateList,skull.i)
   events.EXIT:register(function ()
      skull.data.apps = skull.data.apps
      skull.data.APPS_CHANGED:remove(skull.i)
   end)

   return events
end

avatar:store("gnui.app.home",{
   update = client:getSystemTime(),
   name   = "Home",
   new    = new,
   icon   = textures["textures.home"],
})