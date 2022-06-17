--[[

	Wow TBC 2.4.3 forward port by pbjtime
	https://github.com/pbjtime/

]]

--[[
TODOs
GCD Grid
Drawing order
Options GUI?
--]]
EventHorizon = {}
--e = EventHorizon
EventHorizonDB = {}
local EventHorizon = EventHorizon
EventHorizon.db = EventHorizonDB


local eventhandler
local spellbase = {}
local mainframe

-- Dispatch event to method of the event's name.
local function EventHandler(self, event, ...)
	local f = self[event]
	if f then 
		f(self,...) 
	end 
end

local playerguid

local function printhelp(...) if select('#',...)>0 then return tostring((select(1,...))), printhelp(select(2,...)) end end
local function print(...)
	ChatFrame1:AddMessage(strjoin(',',printhelp(...)))
end

local function UnitDebuffByName(unit, debuff)
	for i = 1, 40 do
		local name, icon, count, debufftype, duration, expirationTime, isMine = UnitDebuff(unit, i)

		if not name then break end

		if name == debuff then
			if duration >= 0 and (isMine == "player") then
				return name, icon, count, debufftype, duration, expirationTime
			end
		end
	end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


function spellbase:NotInteresting(unitid, spellname)
	return unitid ~= 'player' or spellname ~= self.spellname
end

--[[
Indicators represent a point in time. There are different types. The type determines the color, width and position.
--]]
local styles = {
	tick = {
		texture = {1,1,1,1},
		point1 = {'TOP', 'TOP'},
		point2 = {'BOTTOM', 'TOP', 0, -5},
	},
	start = {
		texture = {0,1,0,1},
	},
	stop = {
		texture = {1,0,0,1},
	},
	casting = {
		texture = {0,1,0,0.7},
	},
	cooldown = {
		texture = {1,1,1,0.7},
	},
	smalldebuff = {
		texture = {1,1,1,0.7},
		point1 = {'TOP', 'TOP', 0, -3},
		point2 = {'BOTTOM', 'TOP', -3, -6},
	},
	cantcast = {
		texture = {1,1,1,0.7},
		point1 = {'TOP', 'TOP', 0, -6},
	},
	debuff = {
		texture = {1,1,1,0.7},
	},
	ready = {
		texture = {1,0,1,1},
	},
	default = {
		texture = {1,1,1,1},
		point1 = {'TOP', 'TOP', 0, -5},
		point2 = {'BOTTOM', 'BOTTOM'},
	}
}
EventHorizon.styles = styles
function spellbase:AddIndicator(typeid, time)
	local indicator
	-- TODO recycling
	if #self.unused>0 then
		indicator = tremove(self.unused)
		indicator:ClearAllPoints()
		indicator.time = nil
		indicator.start = nil
		indicator.stop = nil
	else
		indicator = self:CreateTexture(nil, "BORDER")
	end
	local style = styles[typeid]
	local default = styles.default
	local tex = style and style.texture or default.texture
	local point1 = style and style.point1 or default.point1
	local point2 = style and style.point2 or default.point2
	indicator:SetColorTexture(unpack(tex))
	local a,c,d,e = unpack(point1)
	indicator:SetPoint(a,self,c,d,e)
	local a,c,d,e = unpack(point2)
	indicator:SetPoint(a,self,c,d,e)

	indicator:Hide()
	indicator:SetWidth(1)
	indicator.time = time
	indicator.typeid = typeid
	if indicator then
		tinsert(self.indicators, indicator)
	end
	return indicator
end

function spellbase:Remove(indicator)
	for k=1,#self.indicators do
		if self.indicators[k]==indicator then
			indicator:Hide()
			tinsert(self.unused, tremove(self.indicators,k))
			break
		end
	end
end

function spellbase:AddSegment(typeid, start, stop)
	local indicator = self:AddIndicator(typeid, start)
	indicator.time = nil
	indicator.start = start
	indicator.stop = stop
	--print(start,stop)
	return indicator
end

local timeunit = 1
local past = -3
local future = 9
local height = 25
local width = 375
local scale = 1/(future-past)


function spellbase:OnUpdate(elapsed)
	local now = GetTime()
	local diff = now+past
	for k=#self.indicators,1,-1 do
		local indicator = self.indicators[k]
		local time = indicator.time
		if time then
			-- Example: 
			-- [-------|------->--------]
			-- past    now     time     future
			-- now=795, time=800, past=-3, then time is time-now-past after past.
			local p = (time-diff)*scale
			if p<0 then
				indicator:Hide()
				tinsert(self.unused, tremove(self.indicators,k))
			elseif p<=1 then
				indicator:SetPoint("LEFT", self, 'LEFT', p*width, 0)
				indicator:Show()
			end
		else
			local start, stop = indicator.start, indicator.stop
			local p1 = (start-diff)*scale
			local p2 = (stop-diff)*scale
			if p2<0 then
				indicator:Hide()
				tinsert(self.unused, tremove(self.indicators,k))
			elseif 1<p1 then
				indicator:Hide()
			else
				indicator:Show()
				indicator:SetPoint("LEFT", self, 'LEFT', 0<=p1 and p1*375 or 0, 0)
				indicator:SetPoint("RIGHT", self, 'LEFT', p2<=1 and p2*375+1 or 375, 0)
			end
		end
	end
	if self.nexttick and self.nexttick <= now+future then
		if self.nexttick<=self.lasttick then
			self:AddIndicator('tick', self.nexttick)
			self.latesttick = self.nexttick
			self.nexttick = self.nexttick + self.dot
		else
			self.nexttick = nil
		end
	end
end
-- /run e.mf:AddIndicator(GetTime())

function spellbase:OnEvent(event, ...)
	local f = self[event]
	if f then 
		f(self,...) 
	end 
end

function spellbase:UNIT_SPELLCAST_SENT(unitid, target, castGUID, spellID)
	--print('UNIT_SPELLCAST_SENT',unitid, target, castGUID, spellID)
	local spellname = GetSpellInfo(spellID)
	local now = GetTime()
	if self:NotInteresting(unitid, spellname) then return end
	self:AddIndicator('sent', now)
end

function spellbase:UNIT_SPELLCAST_CHANNEL_START(unitid, castGUID, spellID)
	local spellname = GetSpellInfo(spellID)
	if self:NotInteresting(unitid, spellname) then return end
	local name,  text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellId = ChannelInfo(unitid)
	startTime, endTime = startTime/1000, endTime/1000
	self.casting = self:AddSegment('casting', startTime, endTime)
	--self:AddIndicator('start', startTime)
	--self.stop = self:AddIndicator('stop', endTime)
	if self.numhits then
		local casttime = endTime - startTime
		local tick = casttime/self.numhits
		self.ticks = {}
		for i=1,self.numhits do
			tinsert(self.ticks, self:AddIndicator('tick', startTime + i*tick))
		end
	end
end

function spellbase:UNIT_SPELLCAST_CHANNEL_UPDATE(unitid, spellname, spellrank)
	--print('UNIT_SPELLCAST_CHANNEL_UPDATE',unitid, spellname, spellrank)
	if self:NotInteresting(unitid, spellname) then return end
	local name,  text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellId = ChannelInfo(unitid)
	startTime, endTime = startTime/1000, endTime/1000
	if self.casting then
		self.casting.stop = endTime
	end
	local ticks = self.ticks
	if ticks then
		for i = #ticks,1,-1 do
			local tick = ticks[i]
			if tick.time > endTime then
				tick.time = past-1 -- flag for removal
				self.ticks[i] = nil
			end
		end
	end
end

function spellbase:UNIT_SPELLCAST_CHANNEL_STOP(unitid, spellname, spellID)
	local spellname = GetSpellInfo(spellID)
	local now = GetTime()
	if self:NotInteresting(unitid, spellname) then return end
	if self.casting then
		self.casting.stop = now
		self.casting = nil
	end
	local ticks = self.ticks
	if ticks then
		for i = #ticks,1,-1 do
			local tick = ticks[i]
			if tick.time > now then
				tick.time = past-1 -- flag for removal
				self.ticks[i] = nil
			end
		end
		self.ticks = nil
	end
end

function spellbase:UNIT_SPELLCAST_START(unitid, castGUID, spellID)
	local spellname = GetSpellInfo(spellID)
	if self:NotInteresting(unitid, spellname) then return end
	local name, nameSubtext, texture, startTime, endTime, isTradeSkill = CastingInfo()
	startTime, endTime = startTime/1000, endTime/1000
	self.casting = self:AddSegment('casting', startTime, endTime)
end

function spellbase:UNIT_SPELLCAST_STOP(unitid, castGUID, spellID)
	local spellname = GetSpellInfo(spellID)
	local now = GetTime()
	if self:NotInteresting(unitid, spellname) then return end
	if self.casting then
		self.casting.stop = now
		self.casting = nil
	end
end

function spellbase:UNIT_SPELLCAST_DELAYED(unitid, castGUID, spellID)
	local spellname = GetSpellInfo(spellID)
	--print('UNIT_SPELLCAST_CHANNEL_UPDATE',unitid, spellname, spellrank)
	if self:NotInteresting(unitid, spellname) then return end
	local name, nameSubtext, texture, startTime, endTime, isTradeSkill = CastingInfo()
	startTime, endTime = startTime/1000, endTime/1000
	if self.casting and self.stop then
		self.stop.time = endTime
	end
end

function spellbase:UNIT_SPELLCAST_SUCCEEDED(unitid, castGUID, spellID)
	local spellname = GetSpellInfo(spellID)
	if self:NotInteresting(unitid, spellname) then return end
	self.succeeded = GetTime()
end

function spellbase:UNIT_AURA(unitid)
	if unitid~='target' then return end
	local name, icon, count, debuffType, duration, expirationTime = UnitDebuffByName(unitid, self.spellname)
	local afflictedNow = name
	local addnew
	local now = GetTime()
	local start
	if afflictedNow then
		start = expirationTime-duration
		if self.debuff then
			if expirationTime~=self.debuff.stop then
				-- The debuff was replaced.
				self.debuff.stop = start-0.2
				for i = #self.indicators,1,-1 do
					local ind = self.indicators[i]
					if ind.typeid == 'tick' and ind.time>start then
						self:Remove(ind)
					end
				end
				self.nexttick = nil
				addnew = true
			end
		else
			addnew = true
		end
	else
		if self.debuff then
			if math.abs(self.debuff.stop - now)>0.3 then
				self.debuff.stop = now
				for i = #self.indicators,1,-1 do
					local ind = self.indicators[i]
					if ind.typeid == 'tick' and ind.time>now then
						self:Remove(ind)
					end
				end
			end
			self.debuff = nil
			self.nexttick = nil
		end
	end
	if addnew then
		if self.cast then
			self.debuff = self:AddSegment('smalldebuff', start, expirationTime)
			local casttime = select(4, GetSpellInfo(self.spellname))/1000
			self.cooldown = self:AddSegment('cantcast', start, expirationTime-casttime)
		else
			self.debuff = self:AddSegment('debuff', start, expirationTime)
		end
		if self.dot then
			local nexttick = start+self.dot --TODO: haste this for 3.0
			self.nexttick = nil
			while nexttick<=expirationTime do
				if now+future<nexttick then
					self.nexttick = nexttick
					self.lasttick = expirationTime
					break
				end
				if now+past<=nexttick then
					self:AddIndicator('tick', nexttick)
					self.latesttick = nexttick
				end
				nexttick=nexttick+self.dot -- TODO: haste this for 3.0
			end
		end
	end
end

function spellbase:PLAYER_TARGET_CHANGED()
	if self.debuff then
		for i = #self.indicators,1,-1 do
			local ind = self.indicators[i]
			if ind.typeid == 'tick' or ind.typeid == 'cantcast' or ind.typeid == 'debuff' or ind.typeid == 'smalldebuff' then
				self:Remove(ind)
			end
		end
		self.debuff = nil
		self.nexttick = nil
	end

	if UnitExists('target') then
		self:UNIT_AURA('target')
	end
end

--[[
Refreshable debuffs are really ugly, because UnitDebuff won't tell us when the debuff was applied.
It gets complicated because a debuff might be [re]applied/refreshed when we're not looking.
Here's what can happen, and which point of time we have to assume as the start.
success applied -> applied
success applied refresh -> applied
applied success -> success
applied success refresh -> success
applied -> applied
applied refresh -> applied

So we need to keep track of every debuff currently applied, and the success events. 
When the target or debuff changes, we need to look at the time of the last success to see if we can trust UnitDebuff.
--]]
function spellbase:COMBAT_LOG_EVENT_UNFILTERED(...)
	--print(time, event, srcguid,srcname,srcflags, destguid,destname,destflags, spellid,spellname)
	local time, event, _, srcguid, srcname, srcflags, srcRaidFlags, destguid, destname, destflags, destRaidFlags, _, spellname, spellSchool = CombatLogGetCurrentEventInfo()
	if srcguid~=playerguid or event:sub(1,5) ~= 'SPELL' or spellname~=self.spellname then return end
	local now = GetTime()
	if event == 'SPELL_CAST_SUCCESS' then
		--print('SPELL_CAST_SUCCESS',destguid)
		self.castsuccess[destguid] = now
	end
end

function spellbase:UNIT_AURA_refreshable(unitid)
	if unitid~='target' then return end
	local name, icon, count, debuffType, duration, expirationTime = UnitDebuffByName(unitid, self.spellname)
	local afflicted = name
	local addnew, refresh
	local now = GetTime()
	local start
	local guid = UnitGUID('target')
	-- First find out if the debuff was refreshed.
	if afflicted then
		start = expirationTime-duration
		if self.targetdebuff then
			if self.targetdebuff.stop ~= expirationTime then
				local s=self.castsuccess[guid]
				if s then
					local diff = math.abs(s-start)
					--print('diff', diff)
					if diff>0.5 then
						-- The current debuff was refreshed.
						start = self.targetdebuff.start
						refresh = true
						--print("refreshed")
					end
				end
			else
				start = self.targetdebuff.start
			end
		end
		if self.debuff then
			if expirationTime~=self.debuff.stop and not refresh then
				-- The current debuff was replaced.
				self.debuff.stop = start-0.2
				for i = #self.indicators,1,-1 do
					local ind = self.indicators[i]
					if ind.typeid == 'tick' and ind.time>start then
						self:Remove(ind)
					end
				end
				self.nexttick = nil

				--print('replaced')
				addnew = true
			end
		else
			addnew = true
		end
	else
		if self.debuff then
			if math.abs(self.debuff.stop - now)>0.3 then
				-- The current debuff ended.
				self.debuff.stop = now
			end
			self.debuff = nil
		end
	end
	local addticks
	if addnew then
		--print('addnew', start, expirationTime)
		self.debuff = self:AddSegment('debuff', start, expirationTime)
		-- Add visible ticks.
		if self.dot then
			addticks = start
		end
		self.targetdebuff = {start=start, stop=expirationTime}
		self.debuffs[guid] = self.targetdebuff
	elseif refresh then
		--print('refresh', start, expirationTime)
		-- Note: refresh requires afflicted and self.targetdebuff. Also, afflicted and not self.debuff implies addnew.
		-- So we can get here only if afflicted and self.debuff and self.targetdebuff.
		self.debuff.stop = expirationTime
		self.targetdebuff.stop = expirationTime
		if self.latesttick then
			addticks = self.latesttick
		end
	end
	if addticks then
		local nexttick = addticks+self.dot
		self.nexttick = nil
		while nexttick<=expirationTime do
			if now+future<nexttick then
				self.nexttick = nexttick
				self.lasttick = expirationTime
				break
			end
			if now+past<=nexttick then
				self:AddIndicator('tick', nexttick)
				self.latesttick = nexttick
			end
			nexttick=nexttick+self.dot
		end
	end
end

function spellbase:PLAYER_TARGET_CHANGED_refreshable()
	if self.debuff then
		--print('removing old')
		for i = #self.indicators,1,-1 do
			local ind = self.indicators[i]
			if ind.typeid == 'tick' or ind.typeid == 'ready' or ind.typeid == 'debuff' then
				self:Remove(ind)
			end
		end
		self.debuff = nil
		self.targetdebuff = nil
		self.nexttick = nil
	end

	if UnitExists('target') then
		self.targetdebuff = self.debuffs[UnitGUID('target')]
		if self.targetdebuff then
			--print('have old')
		end
		self:UNIT_AURA('target')
	end
end

function spellbase:SPELL_UPDATE_COOLDOWN()
	
	local start, duration, enabled = GetSpellCooldown(self.spellname)
	if enabled==1 and start~=0 and duration and duration>1.5 then
		local ready = start + duration
		if self.cooldown ~= ready then
			self.coolingdown = self:AddSegment('cooldown', start, ready) 
			--self.ready = self:AddIndicator('ready', ready)
			self.cooldown = ready
		end
	else
		if self.coolingdown then
			self.coolingdown = nil
		end
		self.cooldown = nil
	end
end

--[[
spellid: number, rank doesn't matter
abbrev: string
config: table
{
	cast = <cast time in s>,
	channeled = <channel time in s>,
	numhits = <number of hits per channel>,
	cooldown = <boolean>,
	debuff = <duration in s>,
	dot = <tick interval in s, requires debuff>,
	refreshable = <boolean>,
}
--]]
function EventHorizon:NewSpell(spellid, abbrev, config)
	-- TODO check spellbook
	local spellframe = CreateFrame("Frame", nil, mainframe, "BackdropTemplate")
	self[abbrev] = spellframe
	mainframe.numframes = mainframe.numframes+1
	mainframe:SetHeight(mainframe.numframes * height)

	local spellname, rank, tex = GetSpellInfo(spellid)
	spellframe.spellname = spellname

	spellframe.indicators = {}
	spellframe.unused = {}
	spellframe:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 0, -(mainframe.numframes-1) * 25+0)
	spellframe:SetWidth(375)
	spellframe:SetHeight(25)
	spellframe:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	spellframe:SetBackdropColor(1,1,1,.1)
	

	local icon = spellframe:CreateTexture(nil, "BORDER")
	icon:SetTexture(tex)
	icon:SetPoint("TOPRIGHT", spellframe, "TOPLEFT")
	icon:SetWidth(height)
	icon:SetHeight(height)

	local meta = getmetatable(spellframe)
	if meta and meta.__index then
		local metaindex = meta.__index
		setmetatable(spellframe, {__index = 
		function(self,k) 
			if spellbase[k] then 
				self[k]=spellbase[k] 
				return spellbase[k] 
			end 
			return metaindex[k] 
		end})
	else
		setmetatable(spellframe, {__index = spellbase})
	end
	spellframe:RegisterEvent("UNIT_SPELLCAST_SENT")
	if config.channeled then
		spellframe:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		spellframe:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		spellframe:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		spellframe.numhits = config.numhits
	elseif config.cast then
		spellframe.cast = config.cast
		spellframe:RegisterEvent("UNIT_SPELLCAST_START")
		spellframe:RegisterEvent("UNIT_SPELLCAST_STOP")
		spellframe:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	end
	if config.cooldown then
		spellframe:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	end

	if config.debuff then
		spellframe:RegisterEvent("UNIT_AURA")
		spellframe:RegisterEvent("PLAYER_TARGET_CHANGED")
		if config.dot then
			spellframe.dot = config.dot
			if config.refreshable then
				spellframe.UNIT_AURA = spellbase.UNIT_AURA_refreshable
				spellframe.PLAYER_TARGET_CHANGED = spellbase.PLAYER_TARGET_CHANGED_refreshable
				spellframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				spellframe.debuffs = {}
				spellframe.castsuccess = {}
			end
		end
	end
	
	spellframe:SetScript("OnEvent", spellframe.OnEvent)
	spellframe:SetScript("OnUpdate", spellframe.OnUpdate)
end

--[[
Should only be called after the DB is loaded and spell information is available.
--]]
function EventHorizon:Initialize()
	--if not select(2,UnitClass("player"))== then return end
	local class = select(2,UnitClass("player"))
	playerguid = UnitGUID('player')
	if not playerguid then
		error('no playerguid')
	end
	EventHorizon.db = EventHorizonDB

	-- Create the main and spell frames.
	mainframe = CreateFrame("Frame",nil,UIParent, "BackdropTemplate")
	mainframe:SetWidth(375)
	mainframe:SetHeight(25)
	mainframe.numframes = 0
	mainframe:SetScript('OnEvent', EventHandler)

	if class == "PRIEST" then
			self:NewSpell(34917, 'vt', {
			cast = 1.5,
			debuff = 15,
			dot = 3
		})
		
		self:NewSpell(10894, 'swp', {
			debuff = 24,
			dot = 3,
			refreshable = true,
		})				
		
		 self:NewSpell(8092, 'mb', {
		 	cast = 1.5,
		 	cooldown = 5.5,
		 })

		self:NewSpell(18807, 'mf', {
			channeled = 3,
			numhits = 3,
		})
		
		self:NewSpell(32379, 'swd', {
			cooldown = 12,
		})

		self:NewSpell(19280, 'dp', {
			debuff = 24,
			dot = 3,
			cooldown = 180,
		})

		


	elseif class == "WARLOCK" then 
		self:NewSpell(27217, 'mf', {
			channeled = 15,
			numhits = 5,
		})
		self:NewSpell(18265, 'sl', {
			debuff = 30,
			dot = 3,
			refreshable = true,
		})
		self:NewSpell(172, 'cor', {
			debuff = 18,
			dot = 3,
			refreshable = true,
		})
		self:NewSpell(348, 'fb', {
			debuff = 15,
			dot = 3,
			cast = 2,
		})
		self:NewSpell(30108, 'ua', {
			cast = 1.5,
			dot = 3,
			debuff = 18,
		})
		self:NewSpell(980, 'coa', {
			dot = 3,
			debuff = 24,
			refreshable = true,
		})
	else
		return
	end

	local nowIndicator = mainframe:CreateTexture(nil, 'BORDER')
	nowIndicator:SetPoint('BOTTOM',mainframe,'BOTTOM')
	nowIndicator:SetPoint('TOPLEFT',mainframe,'TOPLEFT', -past/(future-past)*width, 0)
	nowIndicator:SetWidth(1)
	nowIndicator:SetColorTexture(1,1,1,1)

	-- GCD indicator
	local gcdIndicator = mainframe:CreateTexture(nil, 'BORDER')
	gcdIndicator:SetPoint('BOTTOM',mainframe,'BOTTOM')
	gcdIndicator:SetPoint('TOP',mainframe,'TOP', -past/(future-past)*width-0.5+height, 0)
	gcdIndicator:SetWidth(1)
	gcdIndicator:SetColorTexture(1,1,1,0.5)
	gcdIndicator:Hide()

	local gcdSpellName = GetSpellInfo(1243)
	do
		local gcdend

		local function OnUpdate(frame, elapsed)
			if gcdend then
				local now = GetTime()
				if gcdend<=now then
					gcdend = nil
					gcdIndicator:Hide()
				else
					local diff = now+past
					local p = (gcdend-diff)*scale
					if p<=1 then
						gcdIndicator:SetPoint('RIGHT', frame, 'RIGHT', (p-1)*width+1, 0)
						gcdIndicator:Show()
					end
				end
			end
		end
		function mainframe:SPELL_UPDATE_COOLDOWN()
			if gcdIndicator then
				local start, duration = GetSpellCooldown(gcdSpellName)
				if start and duration and duration>0 then
					gcdend = start+duration
					mainframe:SetScript('OnUpdate', OnUpdate)
				else
					gcdend = nil
					gcdIndicator:Hide()
					mainframe:SetScript('OnUpdate', nil)
				end
			end
		end
	end

	mainframe:RegisterEvent('SPELL_UPDATE_COOLDOWN')
	

	

	local handle = CreateFrame("Frame", "EventHorizonHandle", UIParent)
	mainframe:SetPoint("TOPRIGHT", handle, "BOTTOMRIGHT")
	self.handle = handle
	handle:SetPoint("CENTER")
	handle:SetWidth(10)
	handle:SetHeight(5)
	handle:EnableMouse(true)
	handle:SetMovable(true)
	handle:RegisterForDrag("LeftButton")
	handle:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
	handle:SetScript("OnDragStop", function(frame) 
		frame:StopMovingOrSizing() 
		local a,b,c,d,e = frame:GetPoint(1)
		if type(b)=='frame' then
			b=b:GetName()
		end
		self.db.point = {a,b,c,d,e}
	end)
	if self.db.point then
		handle:SetPoint(unpack(self.db.point))
	end
	
	handle.tex = handle:CreateTexture(nil, "BORDER")
	handle.tex:SetAllPoints()
	handle:SetScript("OnEnter",function(frame) frame.tex:SetColorTexture(1,1,1,1) end)
	handle:SetScript("OnLeave",function(frame) frame.tex:SetColorTexture(1,1,1,0.1) end)
	handle.tex:SetColorTexture(1,1,1,0.1)
	-- local function MyAddonCommands(msg, editbox)
	--   local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	--   cast = nil
	--   cooldown = nil
	--   debuff = nil
	--   refreshable = false
	--   dot = nil
	--   channeled = nil
	--   numhits = nil
	--   if cmd == 'addspell' then
	--   	spellid, abbrev, cast, cooldown, debuff, refreshable, dot, channeled, numhits  = strsplit(" ",args)
	--     spellid = tonumber(spellid)
	--     cooldown = tonumber(cooldown)
	--     self:NewSpell(spellid, abbrev, {
	--     	cooldown = cooldown,
	--     	cast = cast,
	--     	debuff = debuff,
	--     	refreshable = refreshable,
	--     	dot = dot,
	--     	channeled = channeled,
	--     	numhits = numhits
	--     })
	--     EventHorizon:Initialize()
	--   elseif cmd == 'removespell' then
	--     print('Goodbye, World!')
	--   else
	--     print("Usage: /ehc addspell spellid abbrev cast_time spell_cooldown dot_debuff dot_refreshable dot_tick channeled_time channeled_num_hits")
	--     print("Example for Shadow Word: Death: /ehc addspell 32379 swd nil 12 nil nil nil nil nil")
	--     print("Example for NE racial Starshards: /ehc addspell 25446 starshards nil 30 15 false 3 nil nil")
	--     print("Example for Drain Life: /ehc addspell 689 dl nil nil nil nil nil 5 5")
	--   end
	-- end

	-- SLASH_CMD1, SLASH_CMD2 = '/ehc', '/eh'

	-- SlashCmdList["CMD"] = MyAddonCommands   -- add /hiw and /hellow to command list
	
end

do
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(frame, event, ...) if frame[event] then frame[event](frame,...) end end)
	frame:RegisterEvent("PLAYER_LOGIN")
	function frame:PLAYER_LOGIN()
		EventHorizon:Initialize()
		print("EventHorizon Classic Initialized. In order to edit spells you will need to edit the addon manually for now.")
		print("Slash commands for adding spells is being worked on.")
	end
end


