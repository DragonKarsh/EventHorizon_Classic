SpellFrame = {}
SpellFrame.__index = SpellFrame

setmetatable(SpellFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrame:new(frame, spell, updater)
	self.frame = frame
	self.spell = spell
	self.updater = updater

	if self.updater then
		self.updater:Enable()
	end
end