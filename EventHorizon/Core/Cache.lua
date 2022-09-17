-- "Based" on WeakAuras spell cache. Thanks WeakAuras, you are chads.
local spellCache = {}
EventHorizon.spellCache = spellCache

local appliedByCache = {}
EventHorizon.appliedByCache = appliedByCache

local appliedByLookup = {} -- private
local cache = {}           -- private
local bestIcon = {}        -- private

local GetSpellInfo = GetSpellInfo
local IsSpellKnown = IsSpellKnown
local GetTimePreciseSec = GetTimePreciseSec

-- Builds a cache of name->(id=icon) pairs from existing spell data
-- This is a rather slow operation, so it's only done once, and the result is subsequently saved
function spellCache.Build()
    local start = GetTimePreciseSec()  
    local id = 0
    local misses = 0
    while misses < 80000 do
        id = id + 1
        local name, _, icon = GetSpellInfo(id)

        if(icon == 136243) then -- 136243 is the a gear icon, we can ignore those spells
            misses = 0;
        elseif name and name ~= "" and icon then
        
            cache[name] = cache[name] or {}

            if not cache[name].spells or cache[name].spells == "" then
                cache[name].spells = id .. "=" .. icon
            else
                cache[name].spells = cache[name].spells .. "," .. id .. "=" .. icon
            end
            misses = 0
        else
            misses = misses + 1
        end
    end
end

-- spellCache.GetIcon returns the icon for a spell name, if not determined yet it will try to find the highest spellId matching the spell name
-- to determine the icon
function spellCache.GetBestIconMatchingName(name)
  if (name == nil) then
    return nil;
  end
  if cache then
    if (bestIcon[name]) then
      return bestIcon[name]
    end

    local icons = cache[name]
    local bestMatch = nil
    if (icons) then
      if (icons.spells) then
        for spell, icon in icons.spells:gmatch("(%d+)=(%d+)") do
          local spellId = tonumber(spell)

          if not bestMatch or (spellId and IsSpellKnown(spellId)) then
            bestMatch = tonumber(icon)
          end
        end
      end
    end

    bestIcon[name] = bestMatch
    return bestIcon[name]
  else
    print("EventHorizon: spellCache has not been loaded yet.")
  end
end

function spellCache.GetSpellIDsMatchingName(name)
  if cache[name] then
    if cache[name].spells then
      local result = {}
      local resIdx = 0
      for spellId, _ in cache[name].spells:gmatch("(%d+)=(%d+)") do
        result[resIdx] = tonumber(spellId)
        resIdx = resIdx + 1
      end
      return result
    end
  end
end

function EventHorizon:InitializeCache()
    self.spellCache.Build()
    self.appliedByCache.Build()
end

function appliedByCache.Build()
    local spelldata = {
        [59921] = {        -- Frost Fever
            45477,              -- Icy Touch
            45524               -- Chains of Ice
        },
        [59879] = {         -- Blood Plague
            45462               -- Plague Strike
        }
    }
    
    -- Convert spellids to localized names
    for spellId, appliedBySpells in pairs(spelldata) do
        local spellName = select(1, GetSpellInfo(spellId))
        appliedByLookup[spellName] = {}
        for _, appliedBySpell in ipairs(appliedBySpells) do
            local appliedBySpellName = select(1, GetSpellInfo(appliedBySpell))
            appliedByLookup[spellName][appliedBySpellName] = true
        end
    end
end

function appliedByCache.Get(spellName)
    return appliedByLookup[spellName]
end