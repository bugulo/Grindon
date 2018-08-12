local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Config = Grinder:NewModule("Config", "AceConsole-3.0")

local options = {
    type = "group",
    args = {},
    plugins = {}
}

function Config:OnInitialize()
    options.args.profiles = AceDBOptions:GetOptionsTable(Grinder.Database)

    AceConfig:RegisterOptionsTable("Grinder", options)
    AceConfigDialog:AddToBlizOptions("Grinder", "Grinder")
end

function Config:Register(name, args)
    options.plugins[name] = {
        [name] = {
            type = "group",
            order = 0,
            childGroups = "select",
            name = name,
            args = args
        }
    }
end