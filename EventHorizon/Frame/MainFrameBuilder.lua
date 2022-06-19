MainFrameBuilder = {}
for k, v in pairs(FrameBuilder) do
  MainFrameBuilder[k] = v
end
MainFrameBuilder.__index = MainFrameBuilder

setmetatable(MainFrameBuilder, {
	__index = FrameBuilder,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrameBuilder:new(config)
	FrameBuilder.new(self, config, "EventHorizon", UIParent)
	self.frame.spellFrames = {}
end

function MainFrameBuilder:WithHandle()
	self.handle = Handle(self.config.database)	
	self.frame:SetPoint("TOPRIGHT", self.handle.frame, "BOTTOMRIGHT")
	
	return self
end

function MainFrameBuilder:WithNowReference()
	self.nowReference = NowReference(self.frame)
	return self
end

function MainFrameBuilder:WithGcdReference()
	self.gcdReference = GcdReference(self.frame, self.config.database.profile.gcdSpellId)
	:WithEventHandler()
	:WithUpdater()
	return self
end

function MainFrameBuilder:AsShadowPriest(impSwpRank, has2PcT6, undead)
	local shadowPriest = ShadowPriest(self.config, self.frame)
	:WithImprovedShadowWordPainTalent(impSwpRank)

	if has2PcT6 then
		shadowPriest = shadowPriest:WithTwoPieceTierSix()
	end
	
	self
	:WithSpell(shadowPriest:VampiricTouch())
	:WithSpell(shadowPriest:ShadowWordPain())
	:WithSpell(shadowPriest:MindBlast())
	:WithSpell(shadowPriest:MindFlay())
	:WithSpell(shadowPriest:ShadowWordDeath())

	if undead then
		self:WithSpell(shadowPriest:DevouringPlague())	
	end

	return self
end

function MainFrameBuilder:WithSpell(spellFrame)
	tinsert(self.frame.spellFrames, spellFrame)
	self.frame:SetHeight(#self.frame.spellFrames * self.config.database.profile.height)
	return self
end

function MainFrameBuilder:Build()
	return MainFrame(self.config, self.frame, self.handle, self.nowReference, self.gcdReference)
end