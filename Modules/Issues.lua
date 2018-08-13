local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Issues = Grinder:NewModule("Issues")

local Config = Grinder:GetModule("Config")

local list = {}

local options = {
    header = {
        order = 0,
        type = "header",
        name = "You can find there all issues/bugs that are known in this version"
    },
    list = {
        order = 1,
        name = "- " .. table.concat(list, "\n- "),
        type = "description",
        fontSize = "medium"
    },
}

function Issues:OnInitialize()
    Config:Register("Issues/Bugs", options, 6)
end