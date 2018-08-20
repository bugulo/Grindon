local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Default = Plugin:NewModule("Default", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

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
    if Grindon:IsReserved(itemId) then return end

    local _, itemType = GetItemInfoInstant(itemId)

    Widget:SetItem("Default/" .. itemType, itemId, GetItemIcon(itemId), name, Grindon:GetItemInfo(itemId).count)
end

function Default:RequestHistory(id)
    local response = {}
    for itemId, value in Grindon:IterateItems(id) do
        if not Grindon:IsReserved(itemId) and value.count ~= 0 then
            table.insert(response, {
                Text = value.name,
                Icon = GetItemIcon(itemId),
                Amount = value.count
            })
        end
    end
    return response
end