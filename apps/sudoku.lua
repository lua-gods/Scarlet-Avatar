---@diagnostic disable: undefined-field

-- Function to check if a number is valid to be placed in a Sudoku grid
local function isValid(grid, row, col, num)
   -- Check if the number exists in the current row or column
   for i = 1, 9 do
      if grid[row][i] == num or grid[i][col] == num then
         return false
      end
   end
   
   -- Check if the number exists in the current 3x3 grid
   local startRow, startCol = 3 * math.floor((row - 1) / 3) + 1, 3 * math.floor((col - 1) / 3) + 1
   for i = startRow, startRow + 2 do
      for j = startCol, startCol + 2 do
         if grid[i][j] == num then
            return false
         end
      end
   end
   
   return true
end

local function isWin(result,guess)
   for i = 1, 9 do
      for j = 1, 9 do
         if result[i][j] ~= guess[i][j] then
            return false
         end
      end
   end
   return true
end

-- Function to solve Sudoku recursively using backtracking
local function solveSudoku(grid, row, col)
   -- If we have reached the last cell, Sudoku is solved
   if row > 9 then
      return true
   end
   
   -- If the current cell is already filled, move to the next cell
   if grid[row][col] ~= 0 then
      if col < 9 then
         return solveSudoku(grid, row, col + 1)
      elseif row < 9 then
         return solveSudoku(grid, row + 1, 1)
      else
         return true
      end
   end
   
   -- Try placing numbers 1-9 in the current cell
   local randnum = {}
   for i = 1, 9, 1 do
      table.insert(randnum,math.random(1,#randnum+1),i)
   end
   for i = 1, 9 do
      local num = randnum[i]
      if isValid(grid, row, col, num) then
         grid[row][col] = num
         if col < 9 then
            if solveSudoku(grid, row, col + 1) then
                  return true
            end
         elseif row < 9 then
            if solveSudoku(grid, row + 1, 1) then
               return true
            end
         else
            return true
         end
         grid[row][col] = 0 -- Backtrack if the current configuration doesn't lead to a solution
      end
   end
   
   return false
end

-- Function to generate a Sudoku puzzle
local function generateSudoku()
   -- Create a 9x9 grid with all elements initialized to 0
   local grid = {}
   for i = 1, 9 do
      grid[i] = {}
      for j = 1, 9 do
         grid[i][j] = 0
      end
   end
   grid[math.random(1,9)][math.random(1,9)] = math.random(1,9)
   
   -- Solve the Sudoku grid
   solveSudoku(grid, 1, 1)
   
   return grid
end

---@param gnui GNUI
---@param events GNUI.TV.app
---@param screen GNUI.container
---@param skull WorldSkull
local function new(gnui,screen,events,skull)
   local sprite = gnui.newSprite():setTexture(textures["1x1white"])
   local grid_base = gnui.newContainer():setSprite(sprite:duplicate())
   grid_base:setAnchor(0.5,0,0.5,1)

   local sidebar = gnui.newContainer():setAnchor(0,0,0.5,1)
   screen.Sprite:setTexture(textures["1x1white"]):setColor(1,1,1)

   
   ---@type table<number,GNUI.Label[]>
   local slots = {}

   local selected_pos = vectors.vec2(1,1)
   local function updateColors()
      local hovering = slots[selected_pos.x][selected_pos.y]
      for x = 1, 9, 1 do
         for y = 1, 9, 1 do
            local s = slots[x][y]
            local shade = 1
            local a,b = math.ceil(x / 3 + 1) % 2 == 1,math.ceil(y / 3) % 2 == 1
            if (a or b) and not (a and b) then
               shade = shade - 0.05
            end
            if (x + y + 1) % 2 == 1 then
               shade = shade - 0.02
            end
            s.Sprite:setColor(shade,shade,shade)
         end
      end
      if hovering.Text and #hovering.Text == 1 then
         for x = 1, 9, 1 do
            for y = 1, 9, 1 do
               local s = slots[x][y]
               if s.Text and s.Text[1] and tonumber(s.Text[1].text) then
                  if hovering.Text[1].text == s.Text[1].text then
                     s.Sprite:setColor(s.Sprite.Color:copy():mul(0.8,1,1))
                  end
               end
            end
         end

         -- color column
         for i = 1, 9, 1 do
            local slot =  slots[i][hovering.grid.y]
            slot.Sprite:setColor(slot.Sprite.Color:copy():mul(0.95,1,1))
         end

         -- color row
         for i = 1, 9, 1 do
            local slot =  slots[hovering.grid.x][i]
            slot.Sprite:setColor(slot.Sprite.Color:copy():mul(0.9,1,1))
         end
      end
   end

   for x = 1, 9, 1 do
      slots[x] = {} 
      for y = 1, 9, 1 do
         local c = gnui.newLabel():setSprite(gnui.newSprite()):setAlign(0.5,0.5)
         c:setAnchor((x -1)/9,(y-1)/9,x/9,y/9)
         c.PRESSED:register(function ()
            selected_pos = vectors.vec2(x,y)
            sounds:playSound("minecraft:block.wooden_button.click_on",skull.pos,1,1)
            updateColors()
         end)
         grid_base:addChild(c)
      ---@diagnostic disable-next-line: inject-field
         c.grid = vectors.vec2(x,y)
         slots[x][y] = c
      end
   end

   updateColors()

   events.FRAME:register(function ()
      local size = grid_base.ContainmentRect.zw - grid_base.ContainmentRect.xy
      if size.y > size.x then -- Landscape
         grid_base:setDimensions(-size.y * 0.5,0,size.y * 0.5,0)
         sidebar:setDimensions(1,1,-size.y * 0.5 - 1,-1)
      end
   end)

   local answer = {}
   local guess = {}
   local function set(x,y,v)
      guess[x] = guess[x] or {}
      guess[x][y] = v
      slots[x][y]:setText({text=v,color="gray"})
   end

   local function fill()
      math.randomseed(world.getTime())
      answer = generateSudoku()
      for x = 1,9 do
         for y = 1,9 do
            if math.random() > 0.5 then
               set(x,y,answer[x][y])
            else
               set(x,y,nil)
            end
         end
      end
   end
   fill()

   local next_free_sidebar_button = 0
   local function newSidebarButton(text)
      local new_button = gnui.newLabel()
      :setDimensions(0,next_free_sidebar_button * 11,0,10+next_free_sidebar_button * 11)
      :setAnchor(0,0,1,0)
      if text then
         new_button
         :setSprite(gnui.newSprite():setColor(0.92,0.92,0.92))
         :setAlign(0.5,0.5)
         :setText({text=text,color="gray"})
      end
      sidebar:addChild(new_button)
      next_free_sidebar_button = next_free_sidebar_button + 1
      return new_button
   end

   newSidebarButton("Exit").PRESSED:register(function ()
      events.exit()
   end)

   local t = client:getSystemTime()
   newSidebarButton("Reroll").PRESSED:register(function ()
      if client:getSystemTime() - t < 250 then
         sounds:playSound("minecraft:ui.cartography_table.take_result",skull.pos,1,1)
         fill()
      else
         sounds:playSound("minecraft:item.axe.strip",skull.pos,1,1)
      end
      t = client:getSystemTime()
   end)

   local keypad = gnui.newContainer()
   :setAnchor(0,0,1,0)
   events.FRAME:register(function ()
      keypad:setDimensions(-0.5,next_free_sidebar_button * 11 - 0.5,0.5,sidebar.ContainmentRect.z-sidebar.ContainmentRect.x + next_free_sidebar_button * 11 + 0.5)
   end)
   sidebar:addChild(keypad)

   
   local i = 0
   for y = 2, 0, -1 do
      for x = 0, 2, 1 do
         i = i + 1
         local new_button = gnui.newLabel()
         new_button
         :setDimensions(0.5,0.5,-0.5,-0.5)
         :setAnchor(x/3,y/3,(x+1)/3,(y+1)/3)
         :setSprite(gnui.newSprite():setColor(0.92,0.92,0.92))
         :setAlign(0.5,0.5)
         :setText({text=tostring(i),color="gray"})
         keypad:addChild(new_button)

         local o = i
         new_button.PRESSED:register(function ()
            sounds:playSound("minecraft:block.stone_button.click_on",skull.pos)
            if o == answer[selected_pos.x][selected_pos.y] then
               set(selected_pos.x,selected_pos.y,o)
               if isWin(guess,answer) then
                  sounds:playSound("minecraft:ui.toast.challenge_complete",skull.pos,1,1)
               end
               sounds:playSound("minecraft:entity.experience_orb.pickup",skull.pos,1,1.5)
            else
               sounds:playSound("minecraft:block.note_block.bass",skull.pos,1,0.5)
            end
         end)
      end
   end

   screen:addChild(sidebar)

   screen:addChild(grid_base)
end
avatar:store("gnui.app.sudoku",{
   update = client:getSystemTime(),
   name   = "Sudoku",
   new    = new,
   icon   = textures["textures.icons"],
   icon_atlas_pos = vectors.vec2(3,0)
})

--avatar:store("gnui.force_app","system:sudoku")
--avatar:store("gnui.debug",false)
--avatar:store("gnui.force_app",client:getViewer():getUUID()..":template")