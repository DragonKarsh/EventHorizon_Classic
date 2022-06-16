EventHorizon = {}
EventHorizonDatabase = {}

local EventHorizon = EventHorizon
EventHorizon.database = EventHorizonDatabase

EventHorizon.timeUnit = 1
EventHorizon.past = -3
EventHorizon.future = 9
EventHorizon.height = 25
EventHorizon.width = 375
EventHorizon.scale = 1/(EventHorizon.future-EventHorizon.past)
EventHorizon.gcdSpellId = 1243

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
	self.mainFrame = MainFrame:CreateFrame(self)	

	SpellFrame:CreateFrame(self.mainFrame, {spellId=34917, abbrev='vt', debuff=15, ticks=5, castTime=1.5})
	SpellFrame:CreateFrame(self.mainFrame, {spellId=10894, abbrev='swp', debuff=27, ticks=9})
	SpellFrame:CreateFrame(self.mainFrame, {spellId=8092, abbrev='mb', castTime=1.5, coolDown=5.5})
	SpellFrame:CreateFrame(self.mainFrame, {spellId=25387, abbrev='mf',channel=3, ticks=3})
	SpellFrame:CreateFrame(self.mainFrame, {spellId=32379, abbrev='swd', coolDown=12})
	SpellFrame:CreateFrame(self.mainFrame, {spellId=19280, abbrev='dp', debuff=24, ticks=8, coolDown=180})
end