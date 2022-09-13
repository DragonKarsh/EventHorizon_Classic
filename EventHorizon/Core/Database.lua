EventHorizon.defaults = {
	profile = {
		past = -3,
		future = 9,
		height = 25,
		width = 375,
		texture = "EventHorizon_Smooth",
		border = {0,0,0,1},
		background = {1,1,1,.1},
		casting = {0,1,0,0.9},
		debuff = {1,1,1,0.7},
		buff = {0,0.75,0,0.7},
		coolDown = {0.9,0.9,0.9,0.7},
		ready = {0.5,0.5,0.5,0.7},
		tick = {1,1,1,1},
		sent = {1,1,1,1},
		now=true,
		gcd=true,
		gcdGrid=false,
		nowColor = {1,1,1,1},
		gcdColor = {1,1,1,0.5},
		gcdSpell = 61304,
		enabled = true,
		shown = true,
		locked = false,
		combat = false,
		casts = {},
		channels = {},
		debuffs = {},
		buffs = {},
	}
}

EventHorizon.defaults.profile.scale = 1/(EventHorizon.defaults.profile.future-EventHorizon.defaults.profile.past)

function EventHorizon:InitializeDatabase()
	self.database = LibStub("AceDB-3.0")
	:New("EventHorizonDatabase", self.defaults, true)
	self.opt = self.database.profile
	self.database.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.database.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.database.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

function EventHorizon:OnProfileChanged()
	self.opt = self.database.profile
	self:InitializeAllOptions()
	self:RefreshMainFrame()
end
