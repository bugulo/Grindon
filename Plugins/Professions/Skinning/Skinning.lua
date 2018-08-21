local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Skinning = Plugin:NewModule("Professions_Skinning", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon_Professions_Skinning")

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

    Grindon:Reserve(ids, true)
end

function Skinning:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grindon:Reserve(ids, false)
end

function Skinning:OnSegmentStart()
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Skinning:OnSegmentStop()
    self:UnregisterMessage("OnLootReceive")
end

function Skinning:OnLootReceive(_, itemId, _, name, color)
    if not Grindon:InTable(ids, itemId) then return end

    Widget:SetItem(L["PluginName"], itemId, GetItemIcon(itemId), name, Grindon:GetItemInfo(itemId).count, color)
end

function Skinning:RequestHistory(id)
    local response = {}
    for _, itemId in pairs(ids) do
        local item = Grindon:GetItemInfo(itemId, id)
        if item.count ~= 0 then
            table.insert(response, {
                Text = item.name,
                Icon = GetItemIcon(itemId),
                Amount = item.count
            })
        end
    end
    return response
end