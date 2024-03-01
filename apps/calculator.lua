
local button_text = {
   ".","0","-/+","=",
   "1","2","3","+",
   "4","5","6","-",
   "7","8","9","*",
   "Exit","C","<X]","/",
}

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
   local operator_label = gnui.newLabel()
   last_label:setAlign(1,0):setFontScale(0.75):setAnchor(0,0,1,0.18):setDimensions(2,4,-8,-2)
   operator_label:setAlign(1,0):setFontScale(0.75):setAnchor(0,0,1,0.18):setDimensions(2,4,-2,-2)
   output_label:setAlign(1,1):setAnchor(0,0,1,0.18):setDimensions(2,2,-2,-2)
   screen:addChild(output_label)
   screen:addChild(last_label)
   screen:addChild(operator_label)
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

avatar:store("gnui.force_app","system:calculator")
--avatar:store("gnui.debug",true)

--avatar:store("gnui.force_app",client:getViewer():getUUID()..":calculator")
