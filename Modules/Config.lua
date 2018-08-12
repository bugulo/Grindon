local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Config = Grinder:NewModule("Config", "AceConsole-3.0")

function Config:OnInitialize()
    self.Options = {
        type = "group",
        args = {},
        plugins = {}
    }

    AceConfig:RegisterOptionsTable("Grinder", self.Options)
    AceConfigDialog:AddToBlizOptions("Grinder", "Grinder")
end

function Config:Register(name, options)
    self.Options.plugins[name] = {
        [name] = {
            type = "group",
            childGroups = "select",
            name = name,
            args = options
        }
    }
end