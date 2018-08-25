local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Core = Grindon:NewModule("Core", "AceConsole-3.0", "AceEvent-3.0")

local Config = Grindon:GetModule("Config")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").Core

local database

local options = {
    header = {
        order = 0,
        type = "header",
        name = L["Header"]
    },
    groupLoot = {
        order = 1,
        name = L["GroupLoot"],
        type = "toggle",
        set = function(_, val) database.profile.groupLoot = val end,
        get = function() return database.profile.groupLoot end
    }
}

local defaults = {
    profile = {
        groupLoot = false
    }
}

function Core:OnInitialize()
    database = Grindon:RegisterNamespace("Core", defaults)

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Config:Register(L["ConfigName"], options, 0)
end

function Core:OnSegmentStart()
    self:RegisterEvent("CHAT_MSG_LOOT", "OnLootReceive")
end

function Core:OnSegmentStop()
    self:UnregisterEvent("CHAT_MSG_LOOT")
end

function Core:OnLootReceive(_, msg, _, _, _, player)
    if not database.profile.groupLoot then
        if player ~= UnitName("player") then
            return
        end
    end

    local id = tonumber(string.match(msg, "Hitem:(%d+):"))
    local name = string.match(msg, "%[(.+)%]")
    local count = string.match(msg, "x(%d+)")
    local color = string.match(msg, "|?c?f?f?(%x*)|")
    if count == nil then count = 1 end

    Grindon:GetItemInfo(id).name = name
    Grindon:GetItemInfo(id).count = Grindon:GetItemInfo(id).count + count
    self:SendMessage("OnLootReceive", id, count, name, color)
end