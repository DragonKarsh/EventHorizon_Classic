EventHorizon.options = { 
	name = "EventHorizon",
	handler = EventHorizon,
	type = "group",
	childGroups = "tab",
	args = {
	}	
}

function EventHorizon:InitializeOptions()	
	self:InitializeAllOptions()
	
	LibStub("AceConfig-3.0")
	:RegisterOptionsTable("EventHorizon", self.options, {"eventhorizon", "eh", "evh"})
	
	self.options.args.profiles = LibStub("AceDBOptions-3.0")
	:GetOptionsTable(self.database)

	self.optionsFrame = LibStub("AceConfigDialog-3.0")
	:AddToBlizOptions("EventHorizon", "EventHorizon")
end

function EventHorizon:InitializeAllOptions()
	self:CreateGlobalOptions()
	self:CreateChannelsOptions()
	self:CreateDirectsOptions()
	self:CreateDotsOptions()
	self:CreateChanneledSpellsOptions()
	self:CreateDirectSpellsOptions()
	self:CreateDotSpellsOptions()
end

function EventHorizon:CreateGlobalOptions()
	self.options.args.settings = {
		order = 1,
		name = "Settings",
		desc = "Change global settings",
		type = "group",
		cmdHidden = true,
		args = {
			main = {
				order = 1,
				name = "Main Settings",
				type = "group",
				inline = true,
				args = {
					enabled = {
						order = 1,
						name = "Enable",
						desc = "[Enable/Disable] EventHorizon",
						type = "toggle",
						width = 1.0,
						get = function(info) return EventHorizon.opt.enabled end,
						set = function(info, val) EventHorizon.opt.enabled = val if val then EventHorizon:OnEnable() else EventHorizon:OnDisable() end end
					},
					locked = {
						order = 2,
						name = "Lock",
						desc = "Lock main frame",
						type = "toggle",
						width = 1.0,
						get = function(info) return EventHorizon.opt.locked end,
						set = function(info, val) EventHorizon.opt.locked = val if val then EventHorizon.mainFrame:Lock() else EventHorizon.mainFrame:Unlock() end end
					},
					shown = {
						order = 3,
						name = "Show",
						desc = "Show main frame",
						type = "toggle",
						width = 1.0,
						get = function(info) return EventHorizon.opt.shown end,
						set = function(info, val) EventHorizon.opt.shown = val if val then EventHorizon.mainFrame:Show() else EventHorizon.mainFrame:Hide() end end
					}
				}
			},
			frame = {
				order = 2,
				name = "Frame Settings",
				type = "group",
				inline = true,
				args = {					
					background = {
						order = 1,
						type = "color",
						name = "Background",
						desc = "Set the background color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.background) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.background = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					border = {
						order = 2,
						type = "color",
						name = "Border",
						desc = "Set the border color",
						get = function(info) return unpack(EventHorizon.opt.border) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.border = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					texture = {
						order = 3,
						type = "select",
						name = "Texture",
						desc = "Set the background texture",
						values = EventHorizon.media:HashTable("statusbar"),
						dialogControl = "LSM30_Statusbar",
						get = function(info) return EventHorizon.opt.texture end,
						set = function(info,val)  EventHorizon.opt.texture = val EventHorizon:RefreshMainFrame() end
					},
					width = {
						name = "Width",
						type = "range",
						desc = "Width of a spell frame",
						min = 1,
						max = 500,
						step = 1,
						order = 4,
						get = function(info) return EventHorizon.opt.width end,
						set = function(info,val) EventHorizon:SetWidth(val) end
					},				
					height = {
						name = "Height",
						type = "range",
						desc = "Height of a spell frame",
						min = 1,
						max = 50,
						step = 1,
						order = 5,
						get = function(info) return EventHorizon.opt.height end,
						set = function(info,val) EventHorizon:SetHeight(val) end
					}
					

				}
			},
			timeLine = {
				order = 3,
				name = "Timeline Settings",
				type = "group",
				inline = true,
				args = {
					past = {
						name = "Past",
						type = "range",
						desc = "How many seconds in the past to show",
						min = -10,
						max = 0,
						step = 1,
						order = 1,
						get = function(info) return EventHorizon.opt.past end,
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
						get = function(info) return EventHorizon.opt.future end,
						set = function(info,val) EventHorizon:SetFuture(val) end
					}
				}
			},
			indicators = {
				order = 4,
				name = "Indicators",
				type = "group",
				inline = true,
				args = {					
					now = {
						order = 1,
						name = "Now Indicator",
						desc = "Add now indicator to main frame",
						type = "toggle",
						width = 1.0,
						get = function(info) return EventHorizon.opt.now end,
						set = function(info, val) EventHorizon.opt.now = val EventHorizon.mainFrame:ToggleNowReference(val) end
					},
					gcd = {
						order = 2,
						name = "Gcd Indicator",
						desc = "Add gcd indicator to main frame",
						type = "toggle",
						width = 1.0,
						get = function(info) return EventHorizon.opt.gcd end,
						set = function(info, val) EventHorizon.opt.gcd = val EventHorizon.mainFrame:ToggleGcdReference(val) end
					},
					gcdSpell = {
						order = 3,
						name = "Gcd spell",
						type = "input",
						desc = "Input spell name/id to track Gcd",
						get = function(info) return EventHorizon.opt.gcdSpell end,
						set = function(info,val) EventHorizon.opt.gcdSpell = val end
					}
				}
			}
		}
	}
end


function EventHorizon:CreateChannelsOptions()
	self.options.args.channels = {
		order=2,
		name = "Channels",
		desc = "Edit channeled spells",
		type = "group",
		cmdHidden = true,
		args = {
			createChannel = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new channeled spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewChanneledSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the channeled spell to create",
						order = 2,
						get = function(info) return EventHorizon.newChannelSpell end,
						set = function(info,val) EventHorizon.newChannelSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing channels",
				desc = "Already created channels",
				type = "group"
			}
		}	
	}
end

function EventHorizon:CreateDirectsOptions()
	self.options.args.directs = {
		order=3,
		name = "Directs",
		desc = "Edit direct damage spells",
		type = "group",
		cmdHidden = true,
		args = {
			createDirect = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new direct damage spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewDirectSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the direct damage spell to create",
						order = 2,
						get = function(info) return EventHorizon.newDirectSpell end,
						set = function(info,val) EventHorizon.newDirectSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing direct damage spells",
				desc = "Already created direct damage spells",
				type = "group"
			}
		}
	}
end

function EventHorizon:CreateDotsOptions()
	self.options.args.dots = {
		order=4,
		name = "Dots",
		desc = "Edit damage over time spells",
		type = "group",
		cmdHidden = true,
		args = {
			createDot = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new damage over time spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewDotSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the damage over time spell to create",
						order = 2,
						get = function(info) return EventHorizon.newDotSpell end,
						set = function(info,val) EventHorizon.newDotSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing damage over time spells",
				desc = "Already created channels",
				type = "group"
			}
		}
	}
end

function EventHorizon:CreateNewChanneledSpell()	
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newChannelSpell)

	if spellName and not self.opt.channels[spellName] then
		local channel = {spellId=spellId, ticks=1, enabled=true, order=1}
		self.opt.channels[spellName] = channel
	end	

	self.newChannelSpell = nil
	self:CreateChanneledSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:RemoveChannelSpell(spellName)
	local spellId = self.opt.channels[spellName].spellId
	 self.opt.channels[spellName] = nil
	self:CreateChanneledSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:RemoveDirectSpell(spellName)
	local spellId = self.opt.directs[spellName].spellId
	self.opt.directs[spellName] = nil
	self:CreateDirectSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:RemoveDotSpell(spellName)
	local spellId = self.opt.dots[spellName].spellId
	self.opt.dots[spellName] = nil
	self:CreateDotSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:CreateNewDirectSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newDirectSpell)

	if spellName and not self.opt.directs[spellName] then
		local direct = {spellId=spellId, enabled=true, order=1}
		self.opt.directs[spellName] = direct
	end

	self.newDirectSpell = nil
	self:CreateDirectSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateNewDotSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newDotSpell)
		
	if spellName and not self.opt.dots[spellName] then
		local dot = {spellId=spellId, ticks=1, enabled=true, order=1}
		self.opt.dots[spellName] = dot
	end	

	self.newDotSpell = nil
	self:CreateDotSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateChanneledSpellsOptions()
	local channeledSpells = {		
	}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.channels) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		channeledSpells[k] = {
			order = count,
			name = k,
			icon = select(3,GetSpellInfo(k)),
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.channels[k].enabled end,
					set = function(info, val) EventHorizon.opt.channels[k].enabled = val EventHorizon:RefreshMainFrame() end,
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
					get = function(info) return EventHorizon.opt.channels[k].order end,
					set = function(info, val) EventHorizon.opt.channels[k].order = val EventHorizon:RefreshMainFrame() end,
				},
				ticks = {
					order = 3,
					name = "Ticks",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					get = function(info) return EventHorizon.opt.channels[k].ticks end,
					set = function(info, val) EventHorizon.opt.channels[k].ticks = val EventHorizon:RefreshMainFrame() end
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

	EventHorizon.options.args.channels.args.existing.args = channeledSpells
end

function EventHorizon:CreateDirectSpellsOptions()
	local directSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.directs) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		directSpells[k] = {
			order = count,
			name = k,
			icon = select(3,GetSpellInfo(k)),
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.directs[k].enabled end,
					set = function(info, val) EventHorizon.opt.directs[k].enabled = val EventHorizon:RefreshMainFrame() end,
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
					get = function(info) return EventHorizon.opt.directs[k].order end,
					set = function(info, val) EventHorizon.opt.directs[k].order = val EventHorizon:RefreshMainFrame() end,
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

	EventHorizon.options.args.directs.args.existing.args = directSpells
end

function EventHorizon:CreateDotSpellsOptions()
	local dotSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.dots) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		dotSpells[k] = {
			order = count,
			name = k,
			icon = select(3,GetSpellInfo(k)),
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.dots[k].enabled end,
					set = function(info, val) EventHorizon.opt.dots[k].enabled = val EventHorizon:RefreshMainFrame(k) end,
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
					get = function(info) return EventHorizon.opt.dots[k].order end,
					set = function(info, val) EventHorizon.opt.dots[k].order = val EventHorizon:RefreshMainFrame(k) end,
				},
				ticks = {
					order = 3,
					name = "Ticks",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					get = function(info) return EventHorizon.opt.dots[k].ticks end,
					set = function(info, val) EventHorizon.opt.dots[k].ticks = val EventHorizon:RefreshMainFrame(k) end
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

	EventHorizon.options.args.dots.args.existing.args = dotSpells
end

function EventHorizon:SetHeight(height)
	self.opt.height = height
	self:RefreshMainFrame()
end

function EventHorizon:SetWidth(width)
	self.opt.width = width
	self:RefreshMainFrame()
end

function EventHorizon:SetPast(past)
	self.opt.past = past
	self.opt.scale = 1/(self.opt.future-self.opt.past)
	self:RefreshMainFrame()
end

function EventHorizon:SetFuture(future)
	self.opt.future = future
	self.opt.scale = 1/(self.opt.future-self.opt.past)
	self:RefreshMainFrame()
end