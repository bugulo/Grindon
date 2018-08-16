local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:NewModule("Plugin", "AceConsole-3.0", "AceEvent-3.0")

local Config = Grindon:GetModule("Config")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").Plugin

local options = {
    general = {
        name = "General",
        type = "group",
        order = 0,
        args = {}
    }
}

local defaults = {
    profile = {
        ["Default"] = {enabled = true},
        ["Currency"] = {enabled = true},
        ["*"] = {
            enabled = false
        }
    }
}

function Plugin:OnInitialize()
    self.Database = Grindon.Database:RegisterNamespace("Plugins", defaults)

    self:RegisterMessage("OnProfileChanged", "OnProfileChanged")

    for name, module in self:IterateModules() do
        options.general.args[name] = {
            name = name,
            type = "toggle",
            set = function(_, val) self:ToggleModule(name, val) end,
            get = function() return self.Database.profile[name].enabled end
        }

        if self.Database.profile[name].enabled then module:Enable() end
    end

    Config:Register(L["ConfigName"], options, 3)
end

function Plugin:OnProfileChanged()
    for name, module in self:IterateModules() do
        if self.Database.profile[name].enabled then
            if not module:IsEnabled() then module:Enable() end
        else
            if module:IsEnabled() then module:Disable() end
        end
    end
end

function Plugin:RegisterConfig(name, args, order, disabled)
    if disabled == nil then disabled = false end

    options[name] = {
        type = "group",
        disabled = disabled,
        order = order + 1,
        name = name,
        args = args
    }
end

function Plugin:ToggleModule(name, value)
    if not Grindon.CurrentSegment then
        if value then
            self:GetModule(name):Enable()
        else
            self:GetModule(name):Disable()
        end

        self.Database.profile[name].enabled = value
    else
        self:Print(L["SegmentStarted"])
    end
end

function Plugin:OnModuleCreated(module)
    module:Disable()
end