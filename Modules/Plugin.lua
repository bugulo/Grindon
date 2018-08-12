local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Plugin = Grinder:NewModule("Plugin", "AceConsole-3.0", "AceEvent-3.0")

local Config = Grinder:GetModule("Config")

local options = {
    general = {
        name = "General",
        type = "group",
        args = {}
    }
}

local defaults = {
    global = {
        ["*"] = {
            enabled = true
        }
    }
}

function Plugin:OnInitialize()
    self.Database = Grinder.Database:RegisterNamespace("Plugins", defaults)

    for name, module in self:IterateModules() do
        options.general.args[name] = {
            name = name,
            type = "toggle",
            set = function(_, val) self:ToggleModule(name, val) end,
            get = function() return self.Database.global[name].enabled end
        }

        if self.Database.global[name].enabled then module:Enable() end
    end

    Config:Register("Plugins", options)
end

function Plugin:ToggleModule(name, value)
    if not Grinder.CurrentSegment then
        if value then
            self:GetModule(name):Enable()
        else
            self:GetModule(name):Disable()
        end

        self.Database.global[name].enabled = value
    else
        self:Print("Please stop segment before turning on/off new modules")
    end
end

function Plugin:OnModuleCreated(module)
    module:Disable()
end