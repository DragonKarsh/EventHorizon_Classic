MainFrame = {}
MainFrame.__index = MainFrame

setmetatable(MainFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrame:new(config, frame, handle, now, gcd, spellConfigs)	
	self.frame = frame
	self.config = config

	self.handle = handle
	if self.handle then
		self.frame:SetPoint("TOPRIGHT", self.handle.frame, "BOTTOMRIGHT")
	end

	self.now = now
	self.gcd = gcd

	self.spellFrames = {}

	for _,spellConfig in pairs(spellConfigs) do
		self:NewSpell(spellConfig)
	end		
end

function MainFrame:NewSpell(spellConfig)
	local frame = SpellFrameBuilder(self.config, "Frame", spellConfig.abbrev, self.frame, "BackdropTemplate", spellConfig, #self.spellFrames)
	:WithUpdater()
	:Build()
	tinsert(self.spellFrames, frame)
	self.frame:SetHeight(#self.spellFrames * self.config.height)	
end