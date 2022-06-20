SpellFrame = {}
SpellFrame.__index = SpellFrame

setmetatable(SpellFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrame:new(frame, spell, icon, order)
	self.frame = frame
	self.spell = spell
	self.icon = icon
	self.order = order
end

function SpellFrame:Update(order, enabled)
	self.order = order

	if enabled then 
		self:Enable()
	else 
		self:Disable()
	end
end

function SpellFrame:Enable()
	self.enabled = true
	self.frame:Show()
	self.spell:Enable()
end

function SpellFrame:Disable()
	self.enabled = false
	self.frame:Hide()
	self.spell:Disable()
end