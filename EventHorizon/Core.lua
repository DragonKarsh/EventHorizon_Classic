EventHorizon = {}
EventHorizonDatabase = {}

local EventHorizon = EventHorizon
EventHorizon.database = EventHorizonDatabase

EventHorizon.past = -3
EventHorizon.future = 9
EventHorizon.height = 25
EventHorizon.width = 375
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
	self.mainFrame = MainFrameBuilder(self,"Frame", "EventHorizon", UIParent, "BackdropTemplate")
	:WithHandle(self.database)
	:WithNowReference()
	:WithGcdReference(self.gcdSpellId)
	:WithSpell({spellId=34914, abbrev='vt', debuff=15, ticks=5, castTime=1.5})
	:WithSpell({spellId=589, abbrev='swp', debuff=27, ticks=9})
	:WithSpell({spellId=8092, abbrev='mb', castTime=1.5, coolDown=5.5})
	:WithSpell({spellId=15407, abbrev='mf',channel=3, ticks=3})
	:WithSpell({spellId=32379, abbrev='swd', coolDown=12})
	:WithSpell({spellId=2944, abbrev='dp', debuff=24, ticks=8, coolDown=180})
	:Build()

end