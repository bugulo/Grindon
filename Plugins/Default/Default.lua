local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Plugin = Grinder:GetModule("Plugin")
local Default = Plugin:NewModule("Default", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grinder:GetModule("Widget")

function Default:OnEnable()
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")
end

function Default:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")
end

function Default:OnSegmentStart()
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Default:OnSegmentStop()
    self:UnregisterMessage("OnLootReceive")
end

function Default:OnLootReceive(_, itemId, amount, name)
    if Grinder:IsReserved(itemId) == true then return end

    local _, itemType = GetItemInfoInstant(itemId)

    if Widget:ItemExists("Default", itemType, itemId) then
        Widget:UpdateItem("Default", itemType, itemId, Grinder:GetItemAmount(itemId))
    else
        Widget:SetItem("Default", itemType, itemId, GetItemIcon(itemId), name, Grinder:GetItemAmount(itemId))
    end
end