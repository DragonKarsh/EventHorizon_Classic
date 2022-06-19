EventHorizon = LibStub("AceAddon-3.0")
:NewAddon("EventHorizon")

local defaults = {
	profile = {
		past = -3,
		future = 9,
		height = 25,
		width = 375,
		gcdSpellId = 1243
	}
}

local options = { 
	name = "EventHorizon",
	handler = EventHorizon,
	type = "group",
	args = {
		frameSize = {
			name = "Frame Size",
			type = "group",
			args = {
				width = {
					name = "Width",
					type = "range",
					desc = "Width of a spell frame",
					min = 1,
					max = 500,
					step = 1,
					order = 1,
					get = function(info) return EventHorizon.database.profile.width end,
					set = function(info,val) EventHorizon.database.profile.width = val EventHorizon.mainFrame:Update() end
				},				
				height = {
					name = "Height",
					type = "range",
					desc = "Height of a spell frame",
					min = 1,
					max = 500,
					step = 1,
					order = 2,
					get = function(info) return EventHorizon.database.profile.height end,
					set = function(info,val) EventHorizon.database.profile.height = val EventHorizon.mainFrame:Update() end
				}
			}
		},
		timeLine = {
			name="Timeline",
			type = "group",
			args = {
				past = {
					name = "Past",
					type = "range",
					desc = "How many seconds in the past to show",
					min = -10,
					max = 0,
					step = 1,
					order = 1,
					get = function(info) return EventHorizon.database.profile.past end,
					set = function(info,val) EventHorizon.database.profile.past = val EventHorizon.mainFrame:Update() end
				},
				future = {
					name = "Future",
					type = "range",
					desc = "How many seconds in the future to show",
					min = 0,
					max = 10,
					step = 1,
					order = 2,
					get = function(info) return EventHorizon.database.profile.future end,
					set = function(info,val) EventHorizon.database.profile.future = val EventHorizon.mainFrame:Update() end
				}
			}
		}		
	}	
}



function EventHorizon:OnInitialize()
	self.database = LibStub("AceDB-3.0")
	:New("EventHorizonDatabase", defaults, true)
	
	LibStub("AceConfig-3.0")
	:RegisterOptionsTable("EventHorizon", options)

	self.optionsFrame = LibStub("AceConfigDialog-3.0")
	:AddToBlizOptions("EventHorizon", "EventHorizon")
end

function EventHorizon:OnEnable()
	self.mainFrame = MainFrameBuilder(self)
	:AsShadowPriest(2, true, true) -- 2/2 imp swp, 2pct6, undead
	:WithHandle()
	:WithNowReference()
	:WithGcdReference()
	:Build()
end