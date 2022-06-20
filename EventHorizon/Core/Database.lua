EventHorizon.defaults = {
	profile = {
		past = -3,
		future = 9,
		height = 25,
		width = 375,
		gcdSpellId = 1243,
		channels = {},
		dots = {},
		directs = {}
	}
}

EventHorizon.defaults.profile.scale = 1/(EventHorizon.defaults.profile.future-EventHorizon.defaults.profile.past)

function EventHorizon:InitializeDatabase()
	self.database = LibStub("AceDB-3.0")
	:New("EventHorizonDatabase", self.defaults, true)
end