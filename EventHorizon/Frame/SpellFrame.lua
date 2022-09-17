SpellFrame = {}
SpellFrame.__index = SpellFrame

setmetatable(SpellFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrame:new(frame, spell, spellComponents, icon)
	self.spell = spell
	self.spellId = spell.spellId
	self.spellName = GetSpellInfo(self.spellId)
	self.frame = frame
	self.spellComponents = spellComponents
	self.icon = icon
	self.enabled = self.spell.enabled
end

function SpellFrame:Update(spell)

	self.enabled = spell.enabled
	if self.enabled then 
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

function SpellFrame:Enabled()
	return self.enabled
end

function SpellFrame:Enable()
	self.enabled = true
	self.frame:Show()
	
	for _,spellComponent in pairs(self.spellComponents) do
		spellComponent:Enable()
	end
end

function SpellFrame:Disable()
	self.enabled = false
	self.frame:Hide()
	
	for _,spellComponent in pairs(self.spellComponents) do
		spellComponent:Disable()
	end
end