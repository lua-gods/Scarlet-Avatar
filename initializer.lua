for key, value in pairs(listFiles("autoscripts")) do
   require(value)
end

for key, value in pairs(listFiles("apps")) do
   require(value)
end