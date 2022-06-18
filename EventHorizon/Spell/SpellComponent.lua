SpellComponent = {}
SpellComponent.__index = SpellComponent

setmetatable(SpellComponent, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellComponent:new(spellId, frame)
	self.spellId = spellId
	self.spellName = GetSpellInfo(spellId)
	self.frame = frame

	self.indicators = {}
end

function SpellComponent:WithEventHandler()
	error("abstract method WithEventHandler not implemented")
end

function SpellComponent:WithUpdateHandler()
	self.updateHandler = SpellComponentUpdateHandler(self)
	self.updateHandler:Enable()
	return self
end