local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Default = Plugin:NewModule("Default", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

function Default:OnInitialize()
    --Plugin:RegisterConfig("Default", options, 0, true)
end

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

function Default:OnLootReceive(_, itemId, _, name)
    if Grindon.Reserved[itemId] == true then return end

    local _, itemType = GetItemInfoInstant(itemId)

    Widget:SetItem("Default/" .. itemType, itemId, GetItemIcon(itemId), name, Grindon:GetItemAmount(itemId))
end