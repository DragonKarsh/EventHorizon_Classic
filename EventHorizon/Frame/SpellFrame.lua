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

function SpellFrame:GetFrame()
	return self.frame
end

function SpellFrame:GetIcon()
	return self.icon
end

function SpellFrame:GetChanneler()
	return self.channeler
end

function SpellFrame:GetDebuffer()
	return self.debuffer
end

function SpellFrame:GetSender()
	return self.sender
end

function SpellFrame:GetCaster()
	return self.caster
end

function SpellFrame:GetCoolDowner()
	return self.coolDowner
end

function SpellFrame:Enabled()
	return self.enabled
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