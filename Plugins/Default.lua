local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Default = Grinder:GetModule("Plugin"):NewModule("Default", "AceConsole-3.0", "AceEvent-3.0")

local Display = Grinder:GetModule("Display")

function Default:OnInitialize()
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")
end

function Default:OnSegmentStart()
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Default:OnSegmentStop()
    self:UnregisterMessage("OnLootReceive")
end

function Default:OnLootReceive(_, itemId, amount, name)
    if Grinder:IsReserved(itemId) == true then return end

    if Display:ItemExists("Default", itemId) then
        Display:UpdateItem("Default", itemId, Grinder:GetItemAmount(itemId))
    else
        Display:SetItem("Default", itemId, GetItemIcon(itemId), name, amount)
    end
end