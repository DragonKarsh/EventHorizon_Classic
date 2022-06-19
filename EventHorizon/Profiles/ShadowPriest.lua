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

	self.swpTicks = 6
end

function ShadowPriest:WithTwoPieceTierSix()
	self.swpTicks = self.swpTicks + 1
	return self
end

function ShadowPriest:WithImprovedShadowWordPainTalent(rank)
	if rank < 0 or rank > 2 then error('invalid talent rank') end
	self.swpTicks = self.swpTicks + rank
	return self
end

function ShadowPriest:VampiricTouch()
	return SpellFrameBuilder(self.config, 34914, self.mainFrame)
	:WithDebuff(5)
	:WithCast()
	:WithSender()
	:WithIcon()
	:Build()
end

function ShadowPriest:ShadowWordPain()
	return SpellFrameBuilder(self.config, 589, self.mainFrame)
	:WithDebuff(self.swpTicks)
	:WithSender()
	:WithIcon()
	:Build()
end

function ShadowPriest:MindBlast()
	return SpellFrameBuilder(self.config, 8092, self.mainFrame)	
	:WithCast()
	:WithCoolDown()
	:WithSender()
	:WithIcon()
	:Build()
end

function ShadowPriest:MindFlay()
	return SpellFrameBuilder(self.config, 15407, self.mainFrame)
	:WithChannel(3)
	:WithSender()
	:WithIcon()
	:Build()
end

function ShadowPriest:ShadowWordDeath()
	return SpellFrameBuilder(self.config, 32379, self.mainFrame)
	:WithCoolDown()
	:WithSender()
	:WithIcon()
	:Build()
end

function ShadowPriest:DevouringPlague()
	return SpellFrameBuilder(self.config, 2944, self.mainFrame)
	:WithDebuff(8)
	:WithCoolDown()
	:WithSender()
	:WithIcon()
	:Build()
end
	
