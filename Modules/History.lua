local AceAddon = LibStub("AceAddon-3.0")

local Grindon = AceAddon:GetAddon("Grindon")
local History = Grindon:NewModule("History")

local Config = Grindon:GetModule("Config")

local options = {}

function History:OnInitialize()
    Config:Register("History", options, 2, true)
end