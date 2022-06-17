MainFrame = {}
MainFrame.__index = MainFrame

setmetatable(MainFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrame:new(config)	
	self.config = config
	self.past = config.past
	self.future = config.future
	self.height = config.height
	self.width = config.width
	self.scale = 1/(self.future-self.past)

	self.spellFrames = {}

	self.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")	
	self.frame:SetSize(self.width, self.height)
end

function MainFrame:WithHandle(database)
	self.handle = Handle(database)	
	self.frame:SetPoint("TOPRIGHT", self.handle.frame, "BOTTOMRIGHT")
	return self
end
function MainFrame:WithNowReference()
	self.nowReference = NowReference(self)
	return self
end

function MainFrame:WithGcdReference(gcdSpellId)
	self.gcdReference = GcdReference(self, gcdSpellId)
	:WithEventHandler()
	:WithUpdater()
	return self
end

function MainFrame:NewSpell(spellConfig)
	local frame = SpellFrame(self, spellConfig)
	:WithUpdater()
	tinsert(self.spellFrames, frame)
	self.frame:SetHeight(#self.spellFrames * self.height)	
end