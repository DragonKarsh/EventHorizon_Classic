EventHorizon.options = { 
	name = "EventHorizon",
	handler = EventHorizon,
	type = "group",
	args = {
		frameSize = {
			name = "Frame Size",
			type = "group",
			order=1,
			args = {
				width = {
					name = "Width",
					type = "range",
					desc = "Width of a spell frame",
					min = 1,
					max = 500,
					step = 1,
					order = 1,
					get = function(info) return EventHorizon:GetWidth() end,
					set = function(info,val) EventHorizon:SetWidth(val) end
				},				
				height = {
					name = "Height",
					type = "range",
					desc = "Height of a spell frame",
					min = 1,
					max = 500,
					step = 1,
					order = 2,
					get = function(info) return EventHorizon:GetHeight() end,
					set = function(info,val) EventHorizon:SetHeight(val) end
				}
			}
		},
		timeLine = {
			name="Timeline",
			type = "group",
			order=2,
			args = {
				past = {
					name = "Past",
					type = "range",
					desc = "How many seconds in the past to show",
					min = -10,
					max = 0,
					step = 1,
					order = 1,
					get = function(info) return EventHorizon:GetPast() end,
					set = function(info,val) EventHorizon:SetPast(val) end
				},
				future = {
					name = "Future",
					type = "range",
					desc = "How many seconds in the future to show",
					min = 0,
					max = 10,
					step = 1,
					order = 2,
					get = function(info) return EventHorizon:GetFuture() end,
					set = function(info,val) EventHorizon:SetFuture(val) end
				}
			}
		},
		channels = {
			name = "Channeled Spells",
			type = "group",
			order=3
		},
		directs = {
			name = "Direct Spells",
			type = "group",
			order=4
		},
		dots = {
			name = "Damage Over Time Spells",
			type = "group",
			order=5
		}
	}	
}

function EventHorizon:InitializeOptions()	
	self:CreateChanneledSpellsOptions()
	self:CreateDirectSpellsOptions()
	self:CreateDotSpellsOptions()
	
	LibStub("AceConfig-3.0")
	:RegisterOptionsTable("EventHorizon", self.options, {"eventhorizon", "eh", "evh"})
	
	self.optionsFrame = LibStub("AceConfigDialog-3.0")
	:AddToBlizOptions("EventHorizon", "EventHorizon")
end

function EventHorizon:CreateNewChanneledSpell()
	local spellId = tonumber(self.newChannelSpellId)

	if spellId then
		local spellName = GetSpellInfo(spellId)
		if not self.database.profile.channels[spellName] then
			local channel = {spellId=spellId, ticks=1, enabled=true, order=1}
			self.database.profile.channels[spellName] = channel
		end
	end

	self.newChannelSpellId = nil
	self:CreateChanneledSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:RemoveChannelSpell(spellName)
	local spellId = self.database.profile.channels[spellName].spellId
	 self.database.profile.channels[spellName] = nil
	self:CreateChanneledSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:RemoveDirectSpell(spellName)
	local spellId = self.database.profile.directs[spellName].spellId
	self.database.profile.directs[spellName] = nil
	self:CreateDirectSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:RemoveDotSpell(spellName)
	local spellId = self.database.profile.dots[spellName].spellId
	self.database.profile.dots[spellName] = nil
	self:CreateDotSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)


end

function EventHorizon:CreateNewDirectSpell()
	local spellId = tonumber(self.newDirectSpellId)

	if spellId then
		local spellName = GetSpellInfo(spellId)
		if not self.database.profile.directs[spellName] then
			local direct = {spellId=spellId, enabled=true, order=1}
			self.database.profile.directs[spellName] = direct
		end
	end

	self.newDirectSpellId = nil
	self:CreateDirectSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateNewDotSpell()
	local spellId = tonumber(self.newDotSpellId)

	if spellId then
		local spellName = GetSpellInfo(spellId)
		if not self.database.profile.dots[spellName] then
			local dot = {spellId=spellId, ticks=1, enabled=true, order=1}
			self.database.profile.dots[spellName] = dot
		end
	end

	self.newDotSpellId = nil
	self:CreateDotSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateChanneledSpellsOptions()
	local channeledSpells = {}
	local count = 2

	channeledSpells.newChannel = {
		name = "Create new channeled spell",
		type = "execute",
		order = 1,
		func = function() EventHorizon:CreateNewChanneledSpell() end
	}

	channeledSpells.newChannelSpellId = {
		name = "SpellId",
		type = "input",
		desc = "Enter spellId of the channeled spell to create",
		order = 2,
		get = function(info) return EventHorizon.newChannelSpellId end,
		set = function(info,val) EventHorizon.newChannelSpellId = val end
	}

	local sorted = {}
	for k,v in pairs(self.database.profile.channels) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		channeledSpells[k] = {
			order = count,
			name = k,
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.database.profile.channels[k].enabled end,
					set = function(info, val) EventHorizon.database.profile.channels[k].enabled = val EventHorizon:RefreshMainFrame() end,
					width = "full"
				},
				order = {
					order = 2,
					name = "Order",
					type = "range",
					desc = "Sort order on frame",
					min = 1,
					max = 10,
					step = 1,
					get = function(info) return EventHorizon.database.profile.channels[k].order end,
					set = function(info, val) EventHorizon.database.profile.channels[k].order = val EventHorizon:RefreshMainFrame() end,
				},
				ticks = {
					order = 3,
					name = "Ticks",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					get = function(info) return EventHorizon.database.profile.channels[k].ticks end,
					set = function(info, val) EventHorizon.database.profile.channels[k].ticks = val EventHorizon:RefreshMainFrame() end
				},
				
				remove = {
					order = 4,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveChannelSpell(k) end,				
					width = "full"
				}
			}
		}
	end

	EventHorizon.options.args.channels.args = channeledSpells
end

function EventHorizon:CreateDirectSpellsOptions()
	local directSpells = {}
	local count = 2

	directSpells.newDirect = {
		name = "Create new direct spell",
		type = "execute",
		order = 1,
		func = function() EventHorizon:CreateNewDirectSpell() end
	}

	directSpells.newDirectSpellId = {
		name = "SpellId",
		type = "input",
		desc = "Enter spellId of the direct spell to create",
		order = 2,
		get = function(info) return EventHorizon.newDirectSpellId end,
		set = function(info,val) EventHorizon.newDirectSpellId = val end
	}

	local sorted = {}
	for k,v in pairs(self.database.profile.directs) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		directSpells[k] = {
			order = count,
			name = k,
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.database.profile.directs[k].enabled end,
					set = function(info, val) EventHorizon.database.profile.directs[k].enabled = val EventHorizon:RefreshMainFrame() end,
					width = "full"
				},				
				order = {
					order = 2,
					name = "Order",
					type = "range",
					desc = "Sort order on frame",
					min = 1,
					max = 10,
					step = 1,
					get = function(info) return EventHorizon.database.profile.directs[k].order end,
					set = function(info, val) EventHorizon.database.profile.directs[k].order = val EventHorizon:RefreshMainFrame() end,
				},
				remove = {
					order = 3,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveDirectSpell(k) end,				
					width = "full"
				},
			}
		}
	end

	EventHorizon.options.args.directs.args = directSpells
end


function EventHorizon:CreateDotSpellsOptions()
	local dotSpells = {}
	local count = 2

	dotSpells.newDot = {
		name = "Create new dot spell",
		type = "execute",
		order = 1,
		func = function() EventHorizon:CreateNewDotSpell() end
	}

	dotSpells.newDotSpellId = {
		name = "SpellId",
		type = "input",
		desc = "Enter spellId of the dot spell to create",
		order = 2,
		get = function(info) return EventHorizon.newDotSpellId end,
		set = function(info,val) EventHorizon.newDotSpellId = val end
	}

	local sorted = {}
	for k,v in pairs(self.database.profile.dots) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		dotSpells[k] = {
			order = count,
			name = k,
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.database.profile.dots[k].enabled end,
					set = function(info, val) EventHorizon.database.profile.dots[k].enabled = val EventHorizon:RefreshMainFrame(k) end,
					width = "full"
				},				
				order = {
					order = 2,
					name = "Order",
					type = "range",
					desc = "Sort order on frame",
					min = 1,
					max = 10,
					step = 1,
					get = function(info) return EventHorizon.database.profile.dots[k].order end,
					set = function(info, val) EventHorizon.database.profile.dots[k].order = val EventHorizon:RefreshMainFrame(k) end,
				},
				ticks = {
					order = 3,
					name = "Ticks",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					get = function(info) return EventHorizon.database.profile.dots[k].ticks end,
					set = function(info, val) EventHorizon.database.profile.dots[k].ticks = val EventHorizon:RefreshMainFrame(k) end
				},
				remove = {
					order = 4,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveDotSpell(k) end,				
					width = "full"
				},
			}
		}
	end

	EventHorizon.options.args.dots.args = dotSpells
end

function EventHorizon:GetHeight()
	return EventHorizon.database.profile.height
end

function EventHorizon:SetHeight(height)
	EventHorizon.database.profile.height = height
	self:RefreshMainFrame()
end

function EventHorizon:GetWidth()
	return EventHorizon.database.profile.width
end
function EventHorizon:SetWidth(width)
	EventHorizon.database.profile.width = width
	self:RefreshMainFrame()
end
function EventHorizon:GetPast()
	return EventHorizon.database.profile.past
end
function EventHorizon:SetPast(past)
	EventHorizon.database.profile.past = Past
	EventHorizon.database.profile.scale = 1/(EventHorizon.database.profile.future-EventHorizon.database.profile.past)
	self:RefreshMainFrame()
end
function EventHorizon:GetFuture()
	return EventHorizon.database.profile.future
end
function EventHorizon:SetFuture(future)
	EventHorizon.database.profile.future = future
	EventHorizon.database.profile.scale = 1/(EventHorizon.database.profile.future-EventHorizon.database.profile.past)
	self:RefreshMainFrame()
end