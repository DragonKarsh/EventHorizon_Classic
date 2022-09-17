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
	self:CreateExportImportOptions()
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
					},
					throttle = {
						order = 5,
						name = "Throttle (ms)",
						type = "range",
						desc = "How long in milliseconds to throttle frame updates (increase if having performance issues)",
						min = 0,
						max = 50,
						step = 1,
						get = function(info) return EventHorizon.opt.throttle end,
						set = function(info,val) EventHorizon.opt.throttle = val end
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
						get = function(info) return unpack(EventHorizon.opt.colors.background) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.background = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					border = {
						order = 3,
						type = "color",
						name = "Border",
						desc = "Set the border color",
						get = function(info) return unpack(EventHorizon.opt.colors.border) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.border = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},					
					casting = {
						order = 4,
						type = "color",
						name = "Casting",
						desc = "Set the casting color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.cast) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.cast = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					channeling = {
						order = 5,
						type = "color",
						name = "Channeling",
						desc = "Set the channeling color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.channel) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.channel = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					aura = {
						order = 6,
						type = "color",
						name = "Aura",
						desc = "Set the aura color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.aura) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.aura = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					coolDown = {
						order = 7,
						type = "color",
						name = "Cooldown",
						desc = "Set the cooldown color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.coolDown) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.coolDown = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					ready = {
						order = 8,
						type = "color",
						name = "Ready",
						desc = "Set the ready color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.ready) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.ready = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					tick = {
						order = 9,
						type = "color",
						name = "Tick",
						desc = "Set the tick color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.tick) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.tick = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					sent = {
						order = 10,
						type = "color",
						name = "Sent",
						desc = "Set the sent color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.sent) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.sent = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					nowColor = {
						order = 11,
						type = "color",
						name = "Now",
						desc = "Set the now indicator color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.now) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.now = {r,g,b,a} EventHorizon:RefreshMainFrame() end
					},
					gcdColor = {
						order = 12,
						type = "color",
						name = "Gcd",
						desc = "Set the gcd indicator color",
						hasAlpha = true,
						get = function(info) return unpack(EventHorizon.opt.colors.gcd) end,
						set = function(info,r,g,b,a)  EventHorizon.opt.colors.gcd = {r,g,b,a} EventHorizon:RefreshMainFrame() end
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
						min = -15,
						max = 1,
						step = 1,
						order = 1,
						get = function(info) return EventHorizon.opt.past end,
						set = function(info,val) EventHorizon:SetPast(val) end
					},
					future = {
						name = "Future",
						type = "range",
						desc = "How many seconds in the future to show",
						min = 1,
						max = 15,
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
		name = "Directs",
		desc = "Edit direct spells",
		type = "group",
		cmdHidden = true,
		args = {
			createCast = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new direct spell",
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
						desc = "Enter spellname or spellId of the direct spell to create",
						order = 2,
						get = function(info) return EventHorizon.newCastedSpell end,
						set = function(info,val) EventHorizon.newCastedSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing direct spells",
				desc = "Already created direct spells",
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
		local channel = {
			spellId=spellId, 
			ticks=1, 
			enabled=true, 
			order=1,
			overrideColors=false,
			colors={
				cast=EventHorizon.opt.colors.cast,
				tick=EventHorizon.opt.colors.tick,
				coolDown=EventHorizon.opt.colors.coolDown,
				ready=EventHorizon.opt.colors.ready,
				channel=EventHorizon.opt.colors.channel,
				sent=EventHorizon.opt.colors.sent
			}
		}
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

function EventHorizon:OverrideColors(config)
	if not config.colors then
		config.colors = {}
	end
	if not config.overrideColors then
		config.colors.cast = EventHorizon.opt.colors.cast
		config.colors.channel = EventHorizon.opt.colors.channel
		config.colors.aura = EventHorizon.opt.colors.aura
		config.colors.tick = EventHorizon.opt.colors.tick
		config.colors.ready = EventHorizon.opt.colors.ready
		config.colors.coolDown = EventHorizon.opt.colors.coolDown
		config.colors.sent = EventHorizon.opt.colors.sent
	end
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
		local cast = {
			spellId=spellId, 
			enabled=true, 
			order=1,
			overrideColors=false,
			colors={
				cast=EventHorizon.opt.colors.cast,
				tick=EventHorizon.opt.colors.tick,
				coolDown=EventHorizon.opt.colors.coolDown,
				ready=EventHorizon.opt.colors.ready,
				channel=EventHorizon.opt.colors.channel,
				sent=EventHorizon.opt.colors.sent
			}
		}
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
		local debuff = {
			spellId=spellId, 
			ticks=false, 
			tickType="count", 
			tickCount=1, 
			tickInterval=1, 
			lastTick=false, 
			enabled=true, 
			order=1, 
			overrideColors=false,
			colors={
				cast=EventHorizon.opt.colors.cast,
				tick=EventHorizon.opt.colors.tick,
				coolDown=EventHorizon.opt.colors.coolDown,
				ready=EventHorizon.opt.colors.ready,
				channel=EventHorizon.opt.colors.channel,
				sent=EventHorizon.opt.colors.sent
			}
		}
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
		local buff = {
			spellId=spellId, 
			unitId="player", 
			ticks=false, 
			tickType="count", 
			tickCount=1, 
			tickInterval=1, 
			lastTick=false, 
			enabled=true, 
			order=1,
			overrideColors=false,
			colors={
				cast=EventHorizon.opt.colors.cast,
				tick=EventHorizon.opt.colors.tick,
				coolDown=EventHorizon.opt.colors.coolDown,
				ready=EventHorizon.opt.colors.ready,
				channel=EventHorizon.opt.colors.channel,
				sent=EventHorizon.opt.colors.sent
			}
		}
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
				overrideColors = {
					order = 4,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.channels[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.channels[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.channels[k]) 
						EventHorizon:CreateChanneledSpellsOptions()
						EventHorizon:RefreshMainFrame() end,
					width = "full"
				},	
				colors = {
					order = 5,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.channels[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 6,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveChannelSpell(k) end,				
					width = "full"
				}
			}
		}
		channeledSpells[k].args.colors.args = self:GetColorOptions("channels",k)		
	end

	EventHorizon.options.args.channels.args.existing.args = channeledSpells
end
function EventHorizon:GetColorOptions(spell,spellName)
	return {
			channel = {
				order = 1,
				type = "color",
				name = "Channel",
				desc = "Set the channeling color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon.opt[spell][spellName].colors and EventHorizon.opt[spell][spellName].colors.channel or EventHorizon.opt.colors.channel) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"channel",{r,g,b,a}) EventHorizon:RefreshMainFrame() end
			},
			cast = {
				order = 2,
				type = "color",
				name = "Cast",
				desc = "Set the casting color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon.opt[spell][spellName].colors and EventHorizon.opt[spell][spellName].colors.cast or EventHorizon.opt.colors.cast) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"cast",{r,g,b,a}) EventHorizon:RefreshMainFrame() end
			},
			aura = {
				order = 3,
				type = "color",
				name = "Aura",
				desc = "Set the aura color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon.opt[spell][spellName].colors and EventHorizon.opt[spell][spellName].colors.aura or EventHorizon.opt.colors.aura) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"aura",{r,g,b,a}) EventHorizon:RefreshMainFrame() end
			},
			tick = {
				order = 4,
				type = "color",
				name = "Tick",
				desc = "Set the tick color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon.opt[spell][spellName].colors and EventHorizon.opt[spell][spellName].colors.tick or EventHorizon.opt.colors.tick) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"tick",{r,g,b,a}) EventHorizon:RefreshMainFrame() end
			},
			coolDown = {
				order = 5,
				type = "color",
				name = "Cooldown",
				desc = "Set the cooldown color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon.opt[spell][spellName].colors and EventHorizon.opt[spell][spellName].colors.coolDown or EventHorizon.opt.colors.coolDown) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"coolDown",{r,g,b,a}) EventHorizon:RefreshMainFrame() end
			},
			ready = {
				order = 6,
				type = "color",
				name = "Ready",
				desc = "Set the ready color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon.opt[spell][spellName].colors and EventHorizon.opt[spell][spellName].colors.ready or EventHorizon.opt.colors.ready) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"ready",{r,g,b,a}) EventHorizon:RefreshMainFrame() end
			}
		}
		
end

function EventHorizon:OverrideColor(spell, spellName, color, override)
	if not EventHorizon.opt[spell][spellName].colors then
		EventHorizon.opt[spell][spellName].colors = {}
	end
	EventHorizon.opt[spell][spellName].colors[color] = override
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
				overrideColors = {
					order = 3,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.casts[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.casts[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.casts[k])
						EventHorizon:CreateCastedSpellsOptions()
						EventHorizon:RefreshMainFrame() end,
					width = "full"
				},
					
				colors = {
					order = 4,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.casts[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 5,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveCastedSpell(k) end,				
					width = "full"
				},
			}
		}

		castedSpells[k].args.colors.args = self:GetColorOptions("casts",k)	
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
				overrideColors = {
					order = 9,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.debuffs[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.debuffs[k]) 
						EventHorizon:CreateDebuffSpellsOptions()
						EventHorizon:RefreshMainFrame() 
						end,
					width = "full"
				},							
				colors = {
					order = 10,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.debuffs[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 11,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveDebuffSpell(k) end,				
					width = "full"
				},
			}
		}

		debuffSpells[k].args.colors.args = self:GetColorOptions("debuffs",k)	
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
				overrideColors = {
					order = 10,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.buffs[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.buffs[k]) 
						EventHorizon:CreateBuffSpellsOptions()
						EventHorizon:RefreshMainFrame() end,
					width = "full"
				},						
				colors = {
					order = 11,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.buffs[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 12,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveBuffSpell(k) end,				
					width = "full"
				},
			}
		}

		buffSpells[k].args.colors.args = self:GetColorOptions("buffs",k)	
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

function EventHorizon:CreateExportImportOptions()
	self.options.args.expimp = {
		order=6,
		name = "Export/Import",
		desc = "Export / Import settings",
		type = "group",
		cmdHidden = true,
		args = {
			controls = {
				order = 1,
				name = "Export current settings / Import settings into a profile",
				type = "group",
				inline = true,
				args = {
					exportButton = {
						name = "Export",
						type = "execute",
						order = 1,
						width = "half",
						func = function() self:DoExport() end
					},
					importButton = {
						name = "Import",
						type = "execute",
						order = 2,
						width = "half",
						func = function() if self:DoImport() then self:OnProfileChanged() end end
					},
					newProfile = {
						name = " New profile name",
						type = "input",
						order = 4,
						width = 1.0,
						get = function(info) return self.newProfileName end,
						set = function(info,val) self.newProfileName = val end
					}
				}
			},
			userInput = {
				order = 2,
				name = "    Output/Input",
				type = "input",
				width = "full",
				multiline = 10,
				order = 2,
				get = function(info) return self.exportImportString end,
				set = function(info,val) self.exportImportString = val end
			}
		}
	}
end

function EventHorizon:DoExport()
	local profile = {}
	EventHorizon.Utils:Copy(self.database.profile, profile)

	self.exportImportString = EventHorizon.Utils:CompressAndEncodeObj(profile)
end

function EventHorizon:DoImport()
	if not self.exportImportString then
		print("EventHorizon ERROR: output/input field is empty, or you did not press \"Accept\" after pasting.")
		return false
	end

	if self.newProfileName then
		for _,profileName in pairs(self.database:GetProfiles()) do
			if self.newProfileName == profileName then
				print("EventHorizon ERROR: profile name already exists. delete the old one first if desirable.")
				return false
			end
		end
	else
		print("EventHorizon ERROR: empty profile name")	
		return false
	end

	local newProfile = EventHorizon.Utils:DecodeAndDecompressString(self.exportImportString)
	if newProfile then
		self.database:SetProfile(self.newProfileName)
		self.database:ResetProfile(false, true)
		EventHorizon.Utils:Copy(self:LocalizeSpellOptions(newProfile), self.database.profile)
	else
		print("EventHorizon ERROR: error importing profile data string.")
		return false
	end
	self.exportImportString = nil
	self.newProfileName = nil
	return true
end

function EventHorizon:LocalizeSpellOptions(profile)
	targetCategories = {"debuffs", "buffs", "channels", "casts"}
	for _, category in ipairs(targetCategories) do
		local convertedSpellOptions = {}
		for spellName, spellInfo in pairs(profile[category]) do
			local localizedSpellName = select(1, GetSpellInfo(spellInfo.spellId))
			convertedSpellOptions[localizedSpellName] = spellInfo
		end
		if next(convertedSpellOptions) ~= nil then
			profile[category] = convertedSpellOptions
		end
	end
	return profile
end