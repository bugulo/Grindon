local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Config = Grindon:NewModule("Config", "AceConsole-3.0")

local options = {
    type = "group",
    args = {},
    plugins = {}
}

function Config:OnInitialize()
    options.plugins.profiles = {profiles = Grindon:GetOptionsTable()}
    options.plugins.profiles.profiles.order = 4

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Grindon", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Grindon", "Grindon")
end

function Config:Register(name, args, order, disabled)
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