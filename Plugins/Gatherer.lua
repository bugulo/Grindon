local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Gatherer = Grinder:GetModule("Plugin"):NewModule("Gatherer", "AceConsole-3.0", "AceEvent-3.0")

local Display = Grinder:GetModule("Display")

local spells = {
    "Mining"
}

local ids = {
    123918
}

local defaults = {
    global = {
        segments = {
            ["*"] = {
                nodes = {
                    ["*"] = {
                        count = 0
                    }
                }
            }
        }
    }
}

function Gatherer:OnInitialize()
    self.Database = Grinder.Database:RegisterNamespace("Gatherer", defaults)
    self.LastTarget = nil

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grinder:ReserveIDs(ids)
end

function Gatherer:OnSegmentStart()
    self:RegisterEvent("UNIT_SPELLCAST_START", "OnSpellStart")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellSucceeded")
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Gatherer:OnSegmentStop()
    self:UnregisterEvent("UNIT_SPELLCAST_START")
    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:UnregisterMessage("OnLootReceive")
end

function Gatherer:OnSpellStart(_, unit, _, guid)
    if unit ~= "player" then return end
    local name = GetSpellInfo(guid)
    if not Grinder:InArray(spells, name) then return end

    self.LastTarget = _G["GameTooltipTextLeft1"]:GetText()
end

function Gatherer:OnSpellSucceeded(_, unit, _, guid)
    if unit ~= "player" then return end
    local name = GetSpellInfo(guid)
    if not Grinder:InArray(spells, name) then return end

    self.Database.global.segments[Grinder.CurrentSegment].nodes[self.LastTarget].count = self.Database.global.segments[Grinder.CurrentSegment].nodes[self.LastTarget].count + 1

    if Display:ItemExists("Nodes", self.LastTarget) then
        Display:UpdateItem("Nodes", self.LastTarget, self.Database.global.segments[Grinder.CurrentSegment].nodes[self.LastTarget].count)
    else
        Display:SetItem("Nodes", self.LastTarget, nil, self.LastTarget, 1)
    end
end

function Gatherer:OnLootReceive(_, itemId, amount, name)
    if Grinder:InArray(ids, itemId) ~= true then return end

    if Display:ItemExists("Gathering", itemId) then
        Display:UpdateItem("Gathering", itemId, Grinder:GetItemAmount(itemId))
    else
        Display:SetItem("Gathering", itemId, GetItemIcon(itemId), name, amount)
    end
end