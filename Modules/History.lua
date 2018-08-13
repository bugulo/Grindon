local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local History = Grinder:NewModule("History")

local Config = Grinder:GetModule("Config")

local options = {
}

function Issues:OnInitialize()
    Config:Register("History", options, 2, true)
end