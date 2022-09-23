local GetSpellInfo = GetSpellInfo

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
				cast = {
					r=EventHorizon.opt.colors.cast.r,
					g=EventHorizon.opt.colors.cast.g,
					b=EventHorizon.opt.colors.cast.b,
					a=EventHorizon.opt.colors.cast.a
		
				},
				channel = {
					r=EventHorizon.opt.colors.channel.r,
					g=EventHorizon.opt.colors.channel.g,
					b=EventHorizon.opt.colors.channel.b,
					a=EventHorizon.opt.colors.channel.a
				},
				tick = {
					r=EventHorizon.opt.colors.tick.r,
					g=EventHorizon.opt.colors.tick.g,
					b=EventHorizon.opt.colors.tick.b,
					a=EventHorizon.opt.colors.tick.a
				},
				ready = {
					r=EventHorizon.opt.colors.ready.r,
					g=EventHorizon.opt.colors.ready.g,
					b=EventHorizon.opt.colors.ready.b,
					a=EventHorizon.opt.colors.ready.a
				},
				coolDown = {
					r=EventHorizon.opt.colors.coolDown.r,
					g=EventHorizon.opt.colors.coolDown.g,
					b=EventHorizon.opt.colors.coolDown.b,
					a=EventHorizon.opt.colors.coolDown.a
				},
				sent = {
					r=EventHorizon.opt.colors.sent.r,
					g=EventHorizon.opt.colors.sent.g,
					b=EventHorizon.opt.colors.sent.b,
					a=EventHorizon.opt.colors.sent.a
				},
				aura = {
					r=EventHorizon.opt.colors.aura.r,
					g=EventHorizon.opt.colors.aura.g,
					b=EventHorizon.opt.colors.aura.b,
					a=EventHorizon.opt.colors.aura.a
				}
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