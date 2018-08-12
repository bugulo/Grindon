local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Changelog = Grinder:NewModule("Changelog")

local Config = Grinder:GetModule("Config")

local list = {
    ["v1.0alpha-7f2e175, 12.8.2018"] = {
        "some new thing",
        "some new thing",
    },
    ["v1.0alpha-7f2e174, 12.8.2018"] = {
        "some new thing",
        "some new thing",
    },
    ["v1.0alpha-7f2e173, 12.8.2018"] = {
        "some new thing",
        "some new thing",
    }
}

local options = {}

function Changelog:OnInitialize()
    self:Parse()

    Config:Register("Changelog", options, 0)
end

function Changelog:Parse()
    local i = 0
    for version, list in pairs(list) do
        options[version .. "header"] = {
            order = i,
            type = "header",
            name = version
        }
        options[version .. "list"]  = {
            order = i + 1,
            name = "- " .. table.concat(list, "\n- "),
            type = "description",
            fontSize = "medium"
        }
        i = i + 2
    end
end