SpellFrameBuilder = {}
for k, v in pairs(FrameBuilder) do
  SpellFrameBuilder[k] = v
end
SpellFrameBuilder.__index = SpellFrameBuilder

setmetatable(SpellFrameBuilder, {
	__index = FrameBuilder,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrameBuilder:new(config, frameType, frameName, parentFrame, inheritsFrame, spellConfig, frameNumber)
	FrameBuilder.new(self, config, frameType, frameName, parentFrame, inheritsFrame)

	self.spell = SpellBase(spellConfig, self.frame)

	self.icon = self.frame:CreateTexture(nil, "BORDER")
	local texture = select(3,GetSpellInfo(spellConfig.spellId))
	self.icon:SetTexture(texture)
	self.icon:SetPoint("TOPRIGHT", self.frame, "TOPLEFT")
	self.icon:SetSize(self.frame:GetHeight(), self.frame:GetHeight())

	
	self.frame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -frameNumber * self.frame:GetHeight())	
	self.frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	self.frame:SetBackdropColor(1,1,1,.1)	
end

function SpellFrameBuilder:WithUpdater()
	self.updater = SpellFrameUpdateHandler(self.spell, self.frame)
	return self
end

function SpellFrameBuilder:Build()
	return SpellFrame(self.frame, self.spell, self.updater)
end