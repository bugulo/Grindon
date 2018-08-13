local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Gatherer = Grinder:GetModule("Plugin"):NewModule("Gatherer", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grinder:GetModule("Widget")

local L = AceLocale:GetLocale("Grinder_Gatherer")

local spells = {
    GetSpellInfo(2575),
    GetSpellInfo(2366),
    GetSpellInfo(10768)
}

local ids = {
    mining = {
        -- BFA
        152512, -- Monelite
        152513, -- Platinum ore
        152579, -- Storm Silver ore
        -- LEGION
        123918, -- Leystone ore
        123919, -- Felslate
        124444, -- Infernal Brimstone
        151564, -- Empyrium
    },
    herbalism = {
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
    },
    skinning = {
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
end

function Gatherer:OnEnable()
    self.LastTarget = nil

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grinder:ReserveIDs(ids)
end

function Gatherer:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grinder:UnreserveIDs(ids)
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

    if Widget:ItemExists("Gatherer", L["CATEGORY_NODES"], self.LastTarget) then
        Widget:UpdateItem("Gatherer", L["CATEGORY_NODES"], self.LastTarget, self.Database.global.segments[Grinder.CurrentSegment].nodes[self.LastTarget].count)
    else
        Widget:SetItem("Gatherer", L["CATEGORY_NODES"], self.LastTarget, nil, self.LastTarget, self.Database.global.segments[Grinder.CurrentSegment].nodes[self.LastTarget].count)
    end
end

function Gatherer:OnLootReceive(_, itemId, amount, name)
    local category
    if Grinder:InArray(ids.mining, itemId) == true then
        category = L["CATEGORY_MINING"]
    elseif Grinder:InArray(ids.herbalism, itemId) == true then
        category = L["CATEGORY_HERBALISM"]
    elseif Grinder:InArray(ids.skinning, itemId) == true then
        category = L["CATEGORY_SKINNING"]
    else return end

    if Widget:ItemExists("Gatherer", category, itemId) then
        Widget:UpdateItem("Gatherer", category, itemId, Grinder:GetItemAmount(itemId))
    else
        Widget:SetItem("Gatherer", category, itemId, GetItemIcon(itemId), name, Grinder:GetItemAmount(itemId))
    end
end