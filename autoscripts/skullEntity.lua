
local itemModel = models.skulls.plushie:setParentType("SKULL")
local headModel = models.hat

itemModel:setParentType("Skull")
headModel:setParentType("Skull")
events.SKULL_RENDER:register(function (delta, block, item, entity, context)
   if context == "HEAD" then
      headModel:setVisible(true)
      itemModel:setVisible(false)
   elseif context == "BLOCK" then
      headModel:setVisible(false)
      itemModel:setVisible(false)
   else
      headModel:setVisible(false)
      itemModel:setVisible(true)
   end
end)
