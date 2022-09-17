EventHorizon.defaults = {
	profile = {
		past = -3,
		future = 9,
		height = 25,
		width = 375,
		version = 0,
		throttle = 10,
		texture = "EventHorizon_Smooth",
		colors = {		 
			cast = {0,1,0,0.9},
			channel = {0,1,0,0.9},
			aura = {1,1,1,0.7},
			coolDown = {0.9,0.9,0.9,0.7},
			ready = {0.5,0.5,0.5,0.7},
			tick = {1,1,1,1},
			sent = {1,1,1,1},
			now = {1,1,1,1},
			gcd = {1,1,1,0.5},
			border = {0,0,0,1},
			background = {1,1,1,.1}
		},
		now=true,
		gcd=true,
		gcdSpell = 61304,
		enabled = true,
		shown = true,
		locked = false,
		combat = false,
		casts = {},
		channels = {},
		debuffs = {},
		buffs = {},
		zoom = 0,
	}
}

EventHorizon.defaults.profile.scale = 1/(EventHorizon.defaults.profile.future-EventHorizon.defaults.profile.past)

function EventHorizon:InitializeDatabase()
	self.database = LibStub("AceDB-3.0")
	:New("EventHorizonDatabase", self.defaults, true)
	self.opt = self.database.profile

	self:ApplyConversions()

	self.database.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.database.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.database.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

function EventHorizon:OnProfileChanged()
	self.opt = self.database.profile
	self:ApplyConversions()
	self:InitializeAllOptions()
	self:RefreshMainFrame()
end

function EventHorizon:ApplyConversions()
	--on 2022-09-16, color overrides were introduced. To avoid losing data, apply conversion
	if self.opt.version < 202209160 then
		self:ConvertColors()
		self.opt.version = 202209160
	end
end

function EventHorizon:ConvertColors()	
	if EventHorizon.opt.casting then
		EventHorizon.opt.colors.channel = EventHorizon.opt.casting
	end

	if EventHorizon.opt.casting then
		EventHorizon.opt.colors.cast = EventHorizon.opt.casting
	end

	if EventHorizon.opt.tick then
		EventHorizon.opt.colors.tick = EventHorizon.opt.tick
	end

	if EventHorizon.opt.ready then
		EventHorizon.opt.colors.ready = EventHorizon.opt.ready
	end

	if EventHorizon.opt.coolDown then	
		EventHorizon.opt.colors.coolDown = EventHorizon.opt.coolDown
	end

	if EventHorizon.opt.debuff then
		EventHorizon.opt.colors.aura = EventHorizon.opt.debuff
	end

	if EventHorizon.opt.sent then
		EventHorizon.opt.colors.sent = EventHorizon.opt.sent
	end

	if EventHorizon.opt.gcdColor then
		EventHorizon.opt.colors.gcd = EventHorizon.opt.gcdColor
	end

	if EventHorizon.opt.nowColor then
		EventHorizon.opt.colors.now = EventHorizon.opt.nowColor
	end

	if EventHorizon.opt.border then
		EventHorizon.opt.colors.border = EventHorizon.opt.border
	end

	if EventHorizon.opt.background then
		EventHorizon.opt.colors.background = EventHorizon.opt.background
	end

end


	
