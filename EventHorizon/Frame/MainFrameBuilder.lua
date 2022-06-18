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

function MainFrameBuilder:new(config, frameType, frameName, parentFrame, inheritsFrame)
	FrameBuilder.new(self, config, frameType, frameName, parentFrame, inheritsFrame)

	self.spellConfigs = {}
end

function MainFrameBuilder:WithHandle(database)
	self.handle = Handle(database)	
	return self
end
function MainFrameBuilder:WithNowReference()
	self.nowReference = NowReference(self.frame)
	return self
end

function MainFrameBuilder:WithGcdReference(gcdSpellId)
	self.gcdReference = GcdReference(self.frame, gcdSpellId)
	:WithEventHandler()
	:WithUpdater()
	return self
end

function MainFrameBuilder:WithSpell(spellConfig)
	tinsert(self.spellConfigs, spellConfig)
	return self
end

function MainFrameBuilder:Build()
	return MainFrame(self.config, self.frame, self.handle, self.now, self.gcd, self.spellConfigs)
end