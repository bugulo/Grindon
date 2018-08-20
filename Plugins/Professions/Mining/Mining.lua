local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Mining = Plugin:NewModule("Professions_Mining", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon_Professions_Mining")

local database

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
    database = Grindon:RegisterNamespace("Professions_Mining", defaults)
end

function Mining:OnEnable()
    self.LastTarget = nil

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Grindon:Reserve(ids, true)
end

function Mining:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")

    Grindon:Reserve(ids, false)
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

    local node = database.global.segments[Grindon:GetSegmentID()].nodes[self.LastTarget]

    node.count = node.count + 1

    Widget:SetItem(L["PluginName"] .. "/" .. L["Nodes"], self.LastTarget, nil, self.LastTarget, node.count)
end

function Mining:OnLootReceive(_, itemId, amount, name)
    if not Grindon:InTable(ids, itemId) then return end

    Widget:SetItem(L["PluginName"] .. "/" .. L["Ores"], itemId, GetItemIcon(itemId), name, Grindon:GetItemInfo(itemId).count)
end

function Mining:RequestHistory(id)
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