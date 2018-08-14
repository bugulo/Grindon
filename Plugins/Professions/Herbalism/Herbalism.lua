local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local Grindon = AceAddon:GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Herbalism = Plugin:NewModule("Professions_Herbalism", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = AceLocale:GetLocale("Grindon_Professions_Herbalism")

local spell = GetSpellInfo(2366)

local ids = {
    -- BFA
    152507, -- Akunda's Bite
    152510, -- Anchor Weed
    152505, -- Riverbud
    -- LEGION
    124101, -- Aethril,
    124102, -- Dreamleaf
    124103, -- Foxflower
    124104, -- Fjarnskaggl
    124105, -- Starlight Rose
    124106, -- Felwort
    151565, -- Astral Glory
    152506, -- Star Moss
    152508, -- Winter's Kiss
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

function Herbalism:OnInitialize()
    self.Database = Grindon.Database:RegisterNamespace("Professions_Herbalism", defaults)
end

function Herbalism:OnEnable()
    self.LastTarget = nil

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grindon:ReserveIDs(ids)
end

function Herbalism:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grindon:UnreserveIDs(ids)
end

function Herbalism:OnSegmentStart()
    self:RegisterEvent("UNIT_SPELLCAST_START", "OnSpellStart")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellSucceeded")
    self:RegisterMessage("OnLootReceive", "OnLootReceive")
end

function Herbalism:OnSegmentStop()
    self:UnregisterEvent("UNIT_SPELLCAST_START")
    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:UnregisterMessage("OnLootReceive")
end

function Herbalism:OnSpellStart(_, unit, _, guid)
    if unit ~= "player" then return end
    local name = GetSpellInfo(guid)
    if name ~= spell then return end

    self.LastTarget = _G["GameTooltipTextLeft1"]:GetText()
end

function Herbalism:OnSpellSucceeded(_, unit, _, guid)
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

function Herbalism:OnLootReceive(_, itemId, amount, name)
    if Grindon:InArray(ids, itemId) == false then return end

    if Widget:ItemExists(L["PluginName"], L["Herbs"], itemId) then
        Widget:UpdateItem(L["PluginName"], L["Herbs"], itemId, Grindon:GetItemAmount(itemId))
    else
        Widget:SetItem(L["PluginName"], L["Herbs"], itemId, GetItemIcon(itemId), name, Grindon:GetItemAmount(itemId))
    end
end