local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local Grindon = AceAddon:GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Mining = Plugin:NewModule("Professions_Mining", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = AceLocale:GetLocale("Grindon_Professions_Mining")

local spell = GetSpellInfo(2575)

local ids = {
    -- BFA
    152512, -- Monelite
    152513, -- Platinum ore
    152579, -- Storm Silver ore
    -- LEGION
    123918, -- Leystone ore
    123919, -- Felslate
    124444, -- Infernal Brimstone
    151564, -- Empyrium
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

function Mining:OnInitialize()
    self.Database = Grindon.Database:RegisterNamespace("Professions_Mining", defaults)
end

function Mining:OnEnable()
    self.LastTarget = nil

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grindon:ReserveIDs(ids)
end

function Mining:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grindon:UnreserveIDs(ids)
end

function Mining:OnSegmentStart()
    self:RegisterEvent("UNIT_SPELLCAST_START", "OnSpellStart")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellSucceeded")
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Mining:OnSegmentStop()
    self:UnregisterEvent("UNIT_SPELLCAST_START")
    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:UnregisterMessage("OnLootReceive")
end

function Mining:OnSpellStart(_, unit, _, guid)
    if unit ~= "player" then return end
    local name = GetSpellInfo(guid)
    if name ~= spell then return end

    self.LastTarget = _G["GameTooltipTextLeft1"]:GetText()
end

function Mining:OnSpellSucceeded(_, unit, _, guid)
    if unit ~= "player" then return end
    local name = GetSpellInfo(guid)
    if name ~= spell then return end

    self.Database.global.segments[Grindon.CurrentSegment].nodes[self.LastTarget].count = self.Database.global.segments[Grindon.CurrentSegment].nodes[self.LastTarget].count + 1

    if Widget:ItemExists(L["PluginName"], L["Nodes"], self.LastTarget) then
        Widget:UpdateItem(L["PluginName"], L["Nodes"], self.LastTarget, self.Database.global.segments[Grindon.CurrentSegment].nodes[self.LastTarget].count)
    else
        Widget:SetItem(L["PluginName"], L["Nodes"], self.LastTarget, nil, self.LastTarget, self.Database.global.segments[Grindon.CurrentSegment].nodes[self.LastTarget].count)
    end
end

function Mining:OnLootReceive(_, itemId, amount, name)
    if Grindon:InArray(ids, itemId) == false then return end

    if Widget:ItemExists(L["PluginName"], L["Ores"], itemId) then
        Widget:UpdateItem(L["PluginName"], L["Ores"], itemId, Grindon:GetItemAmount(itemId))
    else
        Widget:SetItem(L["PluginName"], L["Ores"], itemId, GetItemIcon(itemId), name, Grindon:GetItemAmount(itemId))
    end
end