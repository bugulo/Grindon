local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local Grindon = AceAddon:GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Skinning = Plugin:NewModule("Professions_Skinning", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = AceLocale:GetLocale("Grindon_Professions_Skinning")

local ids = {
    -- BFA
    153050, -- Shimmerscale
    153051, -- Mistscale
    152541, -- Coarse Leather
    154722, -- Tempest Hide
    154165, -- Calcified Bone
    154164, -- Blood-Stained Bone
    -- LEGION
    151566, -- Fiendish Leather
    124113, -- Stonehide leather
    124115, -- Stormscale
    124116, -- Felhide
    124439, -- Unbroken Tooth
    124438, -- Unbroken Claw
    129746, -- Oddly-Shaped Stomach
}

function Skinning:OnEnable()
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grindon:ReserveIDs(ids)
end

function Skinning:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grindon:UnreserveIDs(ids)
end

function Skinning:OnSegmentStart()
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Skinning:OnSegmentStop()
    self:UnregisterMessage("OnLootReceive")
end

function Skinning:OnLootReceive(_, itemId, amount, name)
    if Grindon:InArray(ids, itemId) == false then return end

    if Widget:ItemExists(L["PluginName"], L["Default"], itemId) then
        Widget:UpdateItem(L["PluginName"], L["Default"], itemId, Grindon:GetItemAmount(itemId))
    else
        Widget:SetItem(L["PluginName"], L["Default"], itemId, GetItemIcon(itemId), name, Grindon:GetItemAmount(itemId))
    end
end