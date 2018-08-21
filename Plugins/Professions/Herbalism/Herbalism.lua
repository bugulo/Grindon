local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Herbalism = Plugin:NewModule("Professions_Herbalism", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon_Professions_Herbalism")

local database

local spell = GetSpellInfo(2366)

local ids = {
    -- BFA
    152507, -- Akunda's Bite
    152510, -- Anchor Weed
    152505, -- Riverbud
    152511, -- Sea Stalk
    152506, -- Star Moss
    152508, -- Winter's Kiss
    152509, -- Siren's Pollen
    -- LEGION
    124101, -- Aethril,
    124102, -- Dreamleaf
    124103, -- Foxflower
    124104, -- Fjarnskaggl
    124105, -- Starlight Rose
    124106, -- Felwort
    151565, -- Astral Glory
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
    database = Grindon:RegisterNamespace("Professions_Herbalism", defaults)
end

function Herbalism:OnEnable()
    self.LastTarget = nil

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grindon:Reserve(ids, true)
end

function Herbalism:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grindon:Reserve(ids, false)
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

    local node = database.global.segments[Grindon:GetSegmentID()].nodes[self.LastTarget]

    node.count = node.count + 1

    Widget:SetItem(L["PluginName"] .. "/" .. L["Nodes"], self.LastTarget, nil, self.LastTarget, node.count)
end

function Herbalism:OnLootReceive(_, itemId, _, name, color)
    if not Grindon:InTable(ids, itemId) then return end

    Widget:SetItem(L["PluginName"] .. "/" .. L["Herbs"], itemId, GetItemIcon(itemId), name, Grindon:GetItemInfo(itemId).count, color)
end

function Herbalism:RequestHistory(id)
    local response = {}
    local segment = database.global.segments[id]
    for name, node in pairs(segment.nodes) do
        table.insert(response, {Text = name, Icon = nil, Amount = node.count})
    end
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