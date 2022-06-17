SpellBase = {}
SpellBase.__index = SpellBase

setmetatable(SpellBase, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellBase:new (config)
	self.spellId = config.spellId
	self.abbrev = config.abbrev
	self.spellName = GetSpellInfo(config.spellId)	

	self.indicators = {}
	
	if config.castTime then
		self.caster = Caster(self, config.castTime)
		:WithEventHandler()
	end

	if config.channel then
		self.channeler = Channeler(self, config.channel, config.ticks)
		:WithEventHandler()
	end

	if config.debuff then
		self.debuffer = Debuffer(self, config.debuff, config.ticks, config.castTime)
		:WithEventHandler()
	end

	if config.coolDown then
		self.coolDowner = CoolDowner(self, config.coolDown)
		:WithEventHandler()
	end	
end

function SpellBase:SentSpell(time)
	local indicator  = SentIndicator(self, time)
	tinsert(self.indicators, indicator)
end
