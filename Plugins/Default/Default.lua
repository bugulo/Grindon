local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Default = Plugin:NewModule("Default", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon_Default")

local database

local options = {
    header = {
        order = 0,
        type = "header",
        name = L["Header"]
    },
    filter_poor = {
        order = 1,
        name = L.Filter.Quality[1],
        type = "toggle",
        set = function(_, val) Default:ToggleQualityFilter(1, val) end,
        get = function() return database.profile.filter.quality[1].include end
    },
    filter_common = {
        order = 2,
        name = L.Filter.Quality[2],
        type = "toggle",
        set = function(_, val) Default:ToggleQualityFilter(2, val) end,
        get = function() return database.profile.filter.quality[2].include end
    },
    filter_uncommon = {
        order = 3,
        name = L.Filter.Quality[3],
        type = "toggle",
        set = function(_, val) Default:ToggleQualityFilter(3, val) end,
        get = function() return database.profile.filter.quality[3].include end
    },
    filter_rare = {
        order = 4,
        name = L.Filter.Quality[4],
        type = "toggle",
        set = function(_, val) Default:ToggleQualityFilter(4, val) end,
        get = function() return database.profile.filter.quality[4].include end
    },
    filter_epic = {
        order = 5,
        name = L.Filter.Quality[5],
        type = "toggle",
        set = function(_, val) Default:ToggleQualityFilter(5, val) end,
        get = function() return database.profile.filter.quality[5].include end
    },
    filter_legendary = {
        order = 6,
        name = L.Filter.Quality[6],
        type = "toggle",
        set = function(_, val) Default:ToggleQualityFilter(6, val) end,
        get = function() return database.profile.filter.quality[6].include end
    }
}

local defaults = {
    profile = {
        filter = {
            quality = {
                ["*"] = {include = true}
            }
        }
    }
}

function Default:OnInitialize()
    database = Grindon:RegisterNamespace("Default", defaults)

    Plugin:RegisterConfig(L["PluginName"], options, 1)
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

function Default:OnLootReceive(_, itemId, _, name, color)
    if Grindon:IsReserved(itemId) then return end

    local quality = self:GetItemQualityByColor(color)
    if not database.profile.filter.quality[quality + 1].include then return end

    local _, itemType = GetItemInfoInstant(itemId)

    Widget:SetItem(L["PluginName"] .. "/" .. itemType, itemId, GetItemIcon(itemId), name, Grindon:GetItemInfo(itemId).count, color)
end

function Default:ToggleQualityFilter(id, state)
    if not Grindon:IsStarted() then
        database.profile.filter.quality[id].include = state
    else
        self:Print(L["SegmentStarted"])
    end
end

function Default:GetItemQualityByColor(color)
    for i = 0, 5 do
        local _, _, _, hex = GetItemQualityColor(i)
        if hex == "ff" .. color then return i end
    end
    return 1
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