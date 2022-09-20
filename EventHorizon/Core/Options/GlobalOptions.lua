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