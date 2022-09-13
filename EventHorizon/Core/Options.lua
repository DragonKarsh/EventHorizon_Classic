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
	self:CreateCastedOptions()
	self:CreateDebuffsOptions()
	self:CreateBuffsOptions()
	self:CreateChanneledSpellsOptions()
	self:CreateCastedSpellsOptions()
	self:CreateDebuffSpellsOptions()
	self:CreateBuffSpellsOptions()
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
						set = function(info, val) EventHorizon.opt.shown = val EventHorizon.mainFrame:ShowOrHide(false) end
					},
					combat = {
						order = 4,
						name = "In Combat Only",
						desc = "Show main frame when in combat",
						type = "toggle",
						width = 1.0,
						get = function(info) return EventHorizon.opt.combat end,
						set = function(info, val) EventHorizon.opt.combat = val EventHorizon.mainFrame:ShowOrHide(false) end
					}
				}
			},
			frame = {
				order = 2,
				name = "Color Settings",
				type = "group",
				inline = true,
				args = {		
					texture = {
						order = 1,
						type = "select",
						name = "Texture",
						desc = "Set the background texture",
						values = EventHorizon.media:HashTable("statusbar"),
						dialogControl = "LSM30_Statusbar",
						get = function(info) return EventHorizon.opt.texture end,
						set = function(info,val)  EventHorizon.opt.texture = val EventHorizon:RefreshMainFrame() end
					},
					background = {
						order = 2,
						type = "color",
						name = "Background",
						desc = "Set the background color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.background) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.background = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					border = {
						order = 3,
						type = "color",
						name = "Border",
						desc = "Set the border color",
						get = function(info) return unpack(EventHorizon.opt.border) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.border = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},					
					casting = {
						order = 4,
						type = "color",
						name = "Casting/Channeling",
						desc = "Set the casting/channeling color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.casting) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.casting = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					debuff = {
						order = 5,
						type = "color",
						name = "Debuff",
						desc = "Set the debuff color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.debuff) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.debuff = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					buff = {
						order = 6,
						type = "color",
						name = "Buff",
						desc = "Set the buff color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.buff) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.buff = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					coolDown = {
						order = 7,
						type = "color",
						name = "Cooldown",
						desc = "Set the cooldown color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.coolDown) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.coolDown = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					ready = {
						order = 8,
						type = "color",
						name = "Ready",
						desc = "Set the ready color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.ready) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.ready = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					tick = {
						order = 9,
						type = "color",
						name = "Tick",
						desc = "Set the tick color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.tick) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.tick = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					sent = {
						order = 10,
						type = "color",
						name = "Sent",
						desc = "Set the sent color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.sent) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.sent = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					nowColor = {
						order = 11,
						type = "color",
						name = "Now",
						desc = "Set the now indicator color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.nowColor) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.nowColor = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					gcdColor = {
						order = 12,
						type = "color",
						name = "Gcd",
						desc = "Set the gcd indicator color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.gcdColor) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.gcdColor = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					}
				}
			},
			size = {
				order = 3,
				name = "Size Settings",
				type = "group",
				inline = true,
				args = {
					width = {
						name = "Width",
						type = "range",
						desc = "Width of a spell frame",
						min = 1,
						max = 500,
						step = 1,
						order = 1,
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
						order = 2,
						get = function(info) return EventHorizon.opt.height end,
						set = function(info,val) EventHorizon:SetHeight(val) end
					}
				}			
			},
			timeLine = {
				order = 4,
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

function EventHorizon:CreateCastedOptions()
	self.options.args.casts = {
		order=3,
		name = "Casts",
		desc = "Edit casted spells",
		type = "group",
		cmdHidden = true,
		args = {
			createCast = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new casted spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewCastedSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the casted spell to create",
						order = 2,
						get = function(info) return EventHorizon.newCastedSpell end,
						set = function(info,val) EventHorizon.newCastedSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing casted spells",
				desc = "Already created casted spells",
				type = "group"
			}
		}
	}
end

function EventHorizon:CreateDebuffsOptions()
	self.options.args.debuffs = {
		order=4,
		name = "Debuffs",
		desc = "Edit debuff spells",
		type = "group",
		cmdHidden = true,
		args = {
			createDebuff = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new debuff spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewDebuffSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the debuff spell to create",
						order = 2,
						get = function(info) return EventHorizon.newDebuffSpell end,
						set = function(info,val) EventHorizon.newDebuffSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing debuff spells",
				desc = "Already created debuffs",
				type = "group"
			}
		}
	}
end

function EventHorizon:CreateBuffsOptions()
	self.options.args.buffs = {
		order=5,
		name = "Buffs",
		desc = "Edit buff spells",
		type = "group",
		cmdHidden = true,
		args = {
			createBuff = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new buff spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewBuffSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the buff spell to create",
						order = 2,
						get = function(info) return EventHorizon.newBuffSpell end,
						set = function(info,val) EventHorizon.newBuffSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing buff spells",
				desc = "Already created buffs",
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

function EventHorizon:RemoveCastedSpell(spellName)
	local spellId = self.opt.casts[spellName].spellId
	self.opt.casts[spellName] = nil
	self:CreateCastedSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:RemoveDebuffSpell(spellName)
	local spellId = self.opt.debuffs[spellName].spellId
	self.opt.debuffs[spellName] = nil
	self:CreateDebuffSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:RemoveBuffSpell(spellName)
	local spellId = self.opt.buffs[spellName].spellId
	self.opt.buffs[spellName] = nil
	self:CreateBuffSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:CreateNewCastedSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newCastedSpell)

	if spellName and not self.opt.casts[spellName] then
		local cast = {spellId=spellId, enabled=true, order=1}
		self.opt.casts[spellName] = cast
	end

	self.newCastedSpell = nil
	self:CreateCastedSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateNewDebuffSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newDebuffSpell)
	-- if no name was returned, it might be a debuff not from the spell book or typo
	if not spellName then
		local cacheSpells = self.spellCache.GetSpellIDsMatchingName(EventHorizon.newDebuffSpell)
		if cacheSpells then
			for i,cacheSpell in pairs(cacheSpells) do
				local cast = select(4,GetSpellInfo(cacheSpell))
				if cast == nil or cast == 0 then
					-- select highest spellId found without a cast time (aura)
					spellId = cacheSpells[i]
					spellName = EventHorizon.newDebuffSpell
				end
			end
		end
	end
	if spellName and not self.opt.debuffs[spellName] then
		local debuff = {spellId=spellId, ticks=false, tickType="count", tickCount=1, tickInterval=1, lastTick=false, enabled=true, order=1}
		self.opt.debuffs[spellName] = debuff
	end	

	self.newDebuffSpell = nil
	self:CreateDebuffSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateNewBuffSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newBuffSpell)
	-- if no name was returned, it might be a debuff not from the spell book or typo
	if not spellName then
		local cacheSpells = self.spellCache.GetSpellIDsMatchingName(EventHorizon.newBuffSpell)
		if cacheSpells then
			for i,cacheSpell in pairs(cacheSpells) do
				local cast = select(4,GetSpellInfo(cacheSpell))
				if cast == nil or cast == 0 then
					-- select highest spellId found without a cast time (aura)
					spellId = cacheSpells[i]
					spellName = EventHorizon.newBuffSpell
				end
			end
		end
	end
	if spellName and not self.opt.buffs[spellName] then
		local buff = {spellId=spellId, unitId="player", ticks=false, tickType="count", tickCount=1, tickInterval=1, lastTick=false, enabled=true, order=1}
		self.opt.buffs[spellName] = buff
	end	

	self.newBuffSpell = nil
	self:CreateBuffSpellsOptions()
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
			icon = select(3,GetSpellInfo(EventHorizon.opt.channels[k].spellId)),
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

function EventHorizon:CreateCastedSpellsOptions()
	local castedSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.casts) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		castedSpells[k] = {
			order = count,
			name = k,
			icon = select(3,GetSpellInfo(EventHorizon.opt.casts[k].spellId)),
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.casts[k].enabled end,
					set = function(info, val) EventHorizon.opt.casts[k].enabled = val EventHorizon:RefreshMainFrame() end,
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
					get = function(info) return EventHorizon.opt.casts[k].order end,
					set = function(info, val) EventHorizon.opt.casts[k].order = val EventHorizon:RefreshMainFrame() end,
				},
				remove = {
					order = 3,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveCastedSpell(k) end,				
					width = "full"
				},
			}
		}
	end

	EventHorizon.options.args.casts.args.existing.args = castedSpells
end

function EventHorizon:CreateDebuffSpellsOptions()
	local debuffSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.debuffs) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		debuffSpells[k] = {
			order = count,
			name = k,
			icon = self.spellCache.GetBestIconMatchingName(k),
			type = "group",
			width = "half",
			args = {
				spellId = {
					order = 1,
					name = "SpellID: "..EventHorizon.opt.debuffs[k].spellId,
					type = "description",
					width = "full"
				},
				enabled = {
					order = 2,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].enabled end,
					set = function(info, val) EventHorizon.opt.debuffs[k].enabled = val EventHorizon:RefreshMainFrame(k) end,
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
					get = function(info) return EventHorizon.opt.debuffs[k].order end,
					set = function(info, val) EventHorizon.opt.debuffs[k].order = val EventHorizon:RefreshMainFrame(k) end,
				},
				ticks = {
					order = 3,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.debuffs[k].ticks = val self:CreateDebuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 4,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.debuffs[k].ticks = val self:CreateDebuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 5,
					name = "Tick Type",
					desc = "How to set the ticks",
					type = "select",
					values = {["count"]="count",["interval"]="interval"},
					hidden = not EventHorizon.opt.debuffs[k].ticks,
					get = function(info) return EventHorizon.opt.debuffs[k].tickType end,
					set = function(info, val) EventHorizon.opt.debuffs[k].tickType = val self:CreateDebuffSpellsOptions()  EventHorizon:RefreshMainFrame(k) end
				},
				tickCount = {
					order = 6,
					name = "Tick Count",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.debuffs[k].ticks and EventHorizon.opt.debuffs[k].tickType == "count"),
					get = function(info) return EventHorizon.opt.debuffs[k].tickCount end,
					set = function(info, val) EventHorizon.opt.debuffs[k].tickCount = val  EventHorizon:RefreshMainFrame(k) end
				},
				tickInterval = {
					order = 7,
					name = "Tick Interval",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.debuffs[k].ticks and EventHorizon.opt.debuffs[k].tickType == "interval"),
					get = function(info) return EventHorizon.opt.debuffs[k].tickInterval end,
					set = function(info, val) EventHorizon.opt.debuffs[k].tickInterval = val  EventHorizon:RefreshMainFrame(k) end
				},
				lastTick = {
					order = 8,
					name = "Last Tick",
					desc = "End debuff on last detected tick",
					type = "toggle",
					hidden =  not EventHorizon.opt.debuffs[k].ticks,
					get = function(info) return EventHorizon.opt.debuffs[k].lastTick end,
					set = function(info, val) EventHorizon.opt.debuffs[k].lastTick = val  EventHorizon:RefreshMainFrame(k) end
				},
				remove = {
					order = 9,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveDebuffSpell(k) end,				
					width = "full"
				},
			}
		}
	end

	EventHorizon.options.args.debuffs.args.existing.args = debuffSpells
end

function EventHorizon:CreateBuffSpellsOptions()
	local buffSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.buffs) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		buffSpells[k] = {
			order = count,
			name = k,
			icon = self.spellCache.GetBestIconMatchingName(k),
			type = "group",
			width = "half",
			args = {
				spellId = {
					order = 1,
					name = "SpellID: "..EventHorizon.opt.buffs[k].spellId,
					type = "description",
					width = "full"
				},			
				enabled = {
					order = 2,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].enabled end,
					set = function(info, val) EventHorizon.opt.buffs[k].enabled = val EventHorizon:RefreshMainFrame(k) end,
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
					get = function(info) return EventHorizon.opt.buffs[k].order end,
					set = function(info, val) EventHorizon.opt.buffs[k].order = val EventHorizon:RefreshMainFrame(k) end,
				},				
				unitId = {
					order = 3,
					name = "Unit",
					desc = "Which unit this buff targets",
					type = "select",
					values = {["player"]="player",["target"]="target"},
					get = function(info)  return EventHorizon.opt.buffs[k].unitId  end,
					set = function(info, val) EventHorizon.opt.buffs[k].unitId = val  EventHorizon:RefreshMainFrame(k) end
				},
				ticks = {
					order = 4,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.buffs[k].ticks = val self:CreateBuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 5,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.buffs[k].ticks = val self:CreateBuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 6,
					name = "Tick Type",
					desc = "How to set the ticks",
					type = "select",
					hidden =  not EventHorizon.opt.buffs[k].ticks,
					values = {["count"]="count",["interval"]="interval"},
					get = function(info) return EventHorizon.opt.buffs[k].tickType end,
					set = function(info, val) EventHorizon.opt.buffs[k].tickType = val self:CreateBuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end
				},
				tickCount = {
					order = 7,
					name = "Tick Count",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.buffs[k].ticks and EventHorizon.opt.buffs[k].tickType == "count"),
					get = function(info) return EventHorizon.opt.buffs[k].tickCount end,
					set = function(info, val) EventHorizon.opt.buffs[k].tickCount = val  EventHorizon:RefreshMainFrame(k) end
				},
				tickInterval = {
					order = 8,
					name = "Tick Interval",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.buffs[k].ticks and EventHorizon.opt.buffs[k].tickType == "interval"),
					get = function(info) return EventHorizon.opt.buffs[k].tickInterval end,
					set = function(info, val) EventHorizon.opt.buffs[k].tickInterval = val  EventHorizon:RefreshMainFrame(k) end
				},
				lastTick = {
					order = 9,
					name = "Last Tick",
					desc = "End buff on last detected tick",
					type = "toggle",
					hidden =  not EventHorizon.opt.buffs[k].ticks,
					get = function(info) return EventHorizon.opt.buffs[k].lastTick end,
					set = function(info, val) EventHorizon.opt.buffs[k].lastTick = val  EventHorizon:RefreshMainFrame(k) end
				},				
				remove = {
					order = 10,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveBuffSpell(k) end,				
					width = "full"
				},
			}
		}
	end

	EventHorizon.options.args.buffs.args.existing.args = buffSpells
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