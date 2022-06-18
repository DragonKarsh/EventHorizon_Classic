EventHorizon = {}
EventHorizonDatabase = {}

local EventHorizon = EventHorizon
EventHorizon.database = EventHorizonDatabase

EventHorizon.past = -3
EventHorizon.future = 9
EventHorizon.height = 25
EventHorizon.width = 375
EventHorizon.gcdSpellId = 1243 -- Power Word: Fortitude

do
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(frame, event, ...) if frame[event] then frame[event](frame,...) end end)
	frame:RegisterEvent("PLAYER_LOGIN")
	function frame:PLAYER_LOGIN()
		EventHorizon:Initialize()
		print("EventHorizon Classic Initialized")
	end

	EventHorizon.frame = frame
end

function EventHorizon:Initialize()
	self.database = EventHorizonDatabase
	self.mainFrame = MainFrameBuilder(self)
	:AsShadowPriest(2, true, true) -- 2/2 imp swp, 2pct6, undead
	:WithHandle()
	:WithNowReference()
	:WithGcdReference()
	:Build()
end