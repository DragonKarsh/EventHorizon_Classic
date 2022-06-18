ShadowPriest = {}
ShadowPriest.__index = ShadowPriest

setmetatable(ShadowPriest, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function ShadowPriest:new(config, mainFrame)
	self.config = config
	self.mainFrame = mainFrame
end

function ShadowPriest:VampiricTouch()
	return SpellFrameBuilder(self.config, 34914, self.mainFrame)
	:WithDebuff(15,5)
	:WithCast(1.5)
	:WithSender()
	:Build()
end

function ShadowPriest:ShadowWordPain()
	return SpellFrameBuilder(self.config, 589, self.mainFrame)
	:WithDebuff(27,9)
	:WithSender()
	:Build()
end

function ShadowPriest:MindBlast()
	return SpellFrameBuilder(self.config, 8092, self.mainFrame)	
	:WithCast(1.5)
	:WithCoolDown()
	:WithSender()
	:Build()
end

function ShadowPriest:MindFlay()
	return SpellFrameBuilder(self.config, 15407, self.mainFrame)
	:WithChannel(3,3)
	:WithSender()
	:Build()
end

function ShadowPriest:ShadowWordDeath()
	return SpellFrameBuilder(self.config, 32379, self.mainFrame)
	:WithCoolDown()
	:WithSender()
	:Build()
end

function ShadowPriest:DevouringPlague()
	return SpellFrameBuilder(self.config, 2944, self.mainFrame)
	:WithDebuff(24,8)
	:WithCoolDown()
	:WithSender()
	:Build()
end
	
