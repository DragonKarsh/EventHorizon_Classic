SpellBuilder = {}
SpellBuilder.__index = SpellBuilder

setmetatable(SpellBuilder, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellBuilder:new()	
end

function SpellBuilder:WithDebuffer()

function SpellBuilder:Build()
end