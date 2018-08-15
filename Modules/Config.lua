local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Config = Grindon:NewModule("Config", "AceConsole-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").Config

local options = {
    type = "group",
    args = {
        start = {
            type = "execute",
            name = L["StartSegment"],
            func = function() Grindon:StartSegment() end
        },
        stop = {
            type = "execute",
            name = L["StopSegment"],
            func = function() Grindon:StopSegment() end
        }
    },
    plugins = {}
}

function Config:OnInitialize()
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Grindon.Database)
    options.args.profiles.order = 4

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Grindon", options, "grinder")
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Grindon", "Grindon")
end

function Config:Register(name, args, order, disabled)
    if disabled == nil then disabled = false end

    options.plugins[name] = {
        [name] = {
            type = "group",
            disabled = disabled,
            order = order,
            childGroups = "select",
            name = name,
            args = args
        }
    }
end