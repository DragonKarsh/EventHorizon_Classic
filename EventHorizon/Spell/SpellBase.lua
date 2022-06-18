SpellBase = {}
SpellBase.__index = SpellBase

setmetatable(SpellBase, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellBase:new (config, frame)
	self.spellId = config.spellId
	self.abbrev = config.abbrev
	self.spellName = GetSpellInfo(config.spellId)	
	self.frame = frame

	self.indicators = {}

	self.sender = Sender(config.spellId, frame)
	:WithEventHandler()
	:WithUpdateHandler()
	
	if config.castTime then
		self.caster = Caster(config.spellId, frame, config.castTime)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if config.channel then
		self.channeler = Channeler(config.spellId, frame, config.channel, config.ticks)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if config.debuff then
		self.debuffer = Debuffer(config.spellId, frame, config.debuff, config.ticks, config.castTime)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if config.coolDown then
		self.coolDowner = CoolDowner(config.spellId, frame, config.coolDown)
		:WithEventHandler()
		:WithUpdateHandler()
	end	
end
