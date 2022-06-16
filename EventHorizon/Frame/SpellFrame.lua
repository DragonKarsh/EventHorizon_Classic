SpellFrame = {}

function SpellFrame:CreateFrame(mainFrame, spellConfig)
	local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")

	local meta = getmetatable(frame)
	if meta and meta.__index then
		local metaindex = meta.__index
		setmetatable(frame, {__index = 
		function(self,k) 
			if SpellFrame[k] then 
				self[k]=SpellFrame[k] 
				return SpellFrame[k] 
			end 
			return metaindex[k] 
		end})
	else
		setmetatable(frame, {__index = SpellFrame})
	end

	frame.spell = SpellBase(spellConfig)

	frame.mainFrame = mainFrame	
	frame.past = mainFrame.past
	frame.future = mainFrame.future
	frame.width = mainFrame.width
	frame.height = mainFrame.height
	frame.scale = mainFrame.scale

	frame.textures = {}
	frame.unusedTextures = {}	

	local texture = select(3,GetSpellInfo(spellConfig.spellId))
	frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -#mainFrame.spellFrames * mainFrame.height)
	tinsert(mainFrame.spellFrames, frame)
	mainFrame:SetHeight(#mainFrame.spellFrames * mainFrame.height)
	frame:SetWidth(mainFrame.width)
	frame:SetHeight(mainFrame.height)
	frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon_Rowyn\Smooth]]}
	frame:SetBackdropColor(1,1,1,.1)

	local icon = frame:CreateTexture(nil, "BORDER")
	icon:SetTexture(texture)
	icon:SetPoint("TOPRIGHT", frame, "TOPLEFT")
	icon:SetWidth(mainFrame.height)
	icon:SetHeight(mainFrame.height)
	frame.icon = icon	

	frame.updater = SpellFrameUpdater(frame)
	frame.eventHandler = SpellFrameEventHandler(frame)

	return frame
end