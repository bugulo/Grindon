local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local History = Grindon:NewModule("History")

local Config = Grindon:GetModule("Config")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").History

local options = {}

function History:OnInitialize()
    Config:Register(L["ConfigName"], options, 1, true)
end