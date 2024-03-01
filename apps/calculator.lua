---@diagnostic disable: undefined-field

local button_text = {
   ".","0","-/+","=",
   "1","2","3","+",
   "4","5","6","-",
   "7","8","9","*",
   "Exit","C","<X]","/",
}

local tween = require("libraries.GNTweenLib")

---@param gnui GNUI
---@param events GNUI.TV.app
---@param screen GNUI.container
---@param skull WorldSkull
local function new(gnui,screen,events,skull)
   local accent1 = gnui.newSprite():setTexture(textures["textures.endesga"]):setUV(1,0)
   local accent2 = gnui.newSprite():setTexture(textures["textures.endesga"]):setUV(1,3)
   local accent3 = gnui.newSprite():setTexture(textures["textures.endesga"]):setUV(1,2)
   local grid_button = {}
   local grid_size = vectors.vec2(4,6)
   local output_label = gnui.newLabel()
   local last_label = gnui.newLabel()
   local lastlast_label = gnui.newLabel()
   local operator_label = gnui.newLabel()
   local last,lastlast,operator,output = "","","",""
   lastlast_label:setAlign(1,0):setFontScale(0.5):setAnchor(0,0,1,0.18):setDimensions(2,2,-8,-2)
   last_label:setAlign(1,0):setFontScale(0.5):setAnchor(0,0,1,0.18):setDimensions(2,7,-8,-2)
   operator_label:setAlign(1,0):setFontScale(0.5):setAnchor(0,0,1,0.18):setDimensions(2,4,-2,-2)
   output_label:setAlign(1,1):setAnchor(0,0,1,0.18):setDimensions(2,2,-2,-2)
   screen:addChild(output_label)
   screen:addChild(last_label)
   screen:addChild(operator_label)
   screen:addChild(lastlast_label)

   local function update()
      last_label:setText(tostring(last or ""))
      lastlast_label:setText(tostring(lastlast or ""))
      operator_label:setText(tostring(operator or ""))
      output_label:setText(tostring(output or ""))
   end

   local i = 0
   for y = 1, grid_size.y-1, 1 do
      for x = 1, grid_size.x, 1 do
         i = i + 1
         local button = gnui.newLabel()
         :setText(button_text[i])
         :setAlign(0.5,0.5)
         :setAnchor(
            (x-1)/grid_size.x,1-(y/grid_size.y),
            x/grid_size.x,1-((y-1)/grid_size.y))
         :setDimensions(1,1,-1,-1)
         screen:addChild(button)
         grid_button[#grid_button+1] = button
         if x == 4 then
            button:setSprite(accent2:copy())
         else
            if y == 5 then
               button:setSprite(accent3:copy())
            else
               button:setSprite(accent1:copy())
            end
         end
         button.PRESSED:register(function ()
            sounds:playSound("minecraft:block.stone_button.click_on",skull.pos)
            tween.tweenFunction(2,0,0.75,"outElastic",function (t)
               button:setDimensions(1+t,1+t,-1-t,-1-t)
               button:setFontScale(1-t*0.25)
            end,nil,button.Text)
            if tonumber(button.Text) then
               output = output .. button.Text
               update()
            elseif button.Text == "<X]" then
               output = output:sub(1,-2)
               update()
            elseif button.Text:match("[/*-+]") then
               lastlast = last
               last = output
               operator = button.Text
               output = ""
               update()
            elseif button.Text == "=" and last ~= "" and output ~= "" then
               local a,b = tonumber(last),tonumber(output) 
               local answer
               if operator == "+" and a + b == 110 then
                  answer = 100
               elseif operator == "+" then
                  answer = a + b
               elseif operator == "-" then
                  answer = a - b
               elseif operator == "*" then
                  answer = a * b
               elseif operator == "/" then
                  answer = a / b
               end
               lastlast = last
               last = output
               output = tostring(answer)
               update()
            elseif button.Text == "C" then
               last = ""
               lastlast = ""
               operator = ""
               output = ""
               update()
            elseif button.Text == "Exit" then
               events.exit()
            end
            update()
         end)
      end
   end
end
avatar:store("gnui.app.calculator",{
   update = client:getSystemTime(),
   name   = "Calculator",
   new    = new,
   icon   = textures["textures.icons"],
   icon_atlas_pos = vectors.vec2(0,0)
})

--avatar:store("gnui.force_app","system:calculator")
--avatar:store("gnui.debug",true)

--avatar:store("gnui.force_app",client:getViewer():getUUID()..":calculator")
