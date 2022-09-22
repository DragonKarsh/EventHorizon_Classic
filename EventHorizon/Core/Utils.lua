local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary ("LibDeflate")

local Utils = {}
EventHorizon.Utils = Utils

function Utils:CompressAndEncodeObj(object)
    if (LibDeflate and LibAceSerializer) then
        local dataSerialized = LibAceSerializer:Serialize(object)
        if (dataSerialized) then
            local dataCompressed = LibDeflate:CompressDeflate(dataSerialized, {level = 9})
            if (dataCompressed) then
                local dataEncoded = LibDeflate:EncodeForPrint(dataCompressed)
                return dataEncoded
            end
        end
    end
end

function Utils:DecodeAndDecompressString(dataString)
    if (LibDeflate and LibAceSerializer) then
        local dataCompressed
        
        dataCompressed = LibDeflate:DecodeForPrint(dataString)
        if (not dataCompressed) then
            print("EventHorizon: ERROR: decoding profile string")
            return false
        end
        
        local dataSerialized = LibDeflate:DecompressDeflate(dataCompressed)
        if (not dataSerialized) then
            print("EventHorizon: ERROR: decompressing profile string")
            return false
        end
        
        local okay, data = LibAceSerializer:Deserialize(dataSerialized)
        if (not okay) then
            print("EventHorizon: ERROR: deserializing profile string")
            return false
        end
        
        if not Utils:ValidateData(data) then
            print("EventHorizon: ERROR: import string is not supported")
            return false
        end
        return data
    end
end

function Utils:Copy(fromTable, toTable)
	for key, value in pairs(fromTable) do
		if (key ~= "__index" and key ~= "__newindex") then
			if (type (value) == "table") then
				toTable[key] = toTable[key] or {}
				Utils:Copy(fromTable[key], toTable[key])
			else
				toTable[key] = value
			end
		end
	end
end

function Utils:ValidateData(data)
    if type(data) ~= "table" then return false end

    for key, value in pairs(data) do
        if type(value) == "function" then return false end

        if (type(value) == "table") then
            if not Utils:ValidateData(data[key]) then return false end
        end
    end
    return true
end

function Utils:UnpackColor(color)
	return color.r, color.g, color.b, color.a
end
