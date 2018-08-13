local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Changelog = Grinder:NewModule("Changelog")

local Config = Grinder:GetModule("Config")

local list = {
    ["v0.1 - 13.8.2018"] = {
        "Core Grinder functionality",
        "Start segments via /startgrind & stop it with /stopgrind",
        "Frequency meter in segment widget (items per minute)",
        "Toggle categories/plugins by left clicking on them",
        "Hide temporary specific items by right clicking on them",
        "Setup your profiles in config window",
        "Enable or disable specific plugins of Grinder\n",
        "Plugin/Default",
        "As Grinder is not covering many activies yet, default module is tracking all items you loot and placing them into categories\n",
        "Plugin/Currencies",
        "Track loot of all currencies and money\n",
        "Plugin/Gatherer",
        "Initial support for Battle for Azeroth and Legion",
        "Track loot of all gathering professions(Mining, Skinning, Herbalism)",
        "Count how many and which nodes did you take"
    },
}

local options = {
    notice = {
        order = 0,
        type = "header",
        name = "!!! NOTICE !!!"
    },
    notice_content = {
        order = 1,
        name = "Please keep in mind that Grinder is in an early stage of development. Although core parts of Grinder are done, there are not many plugins right now and customization of specific features is weak as of now. Grinder is currently localized only into enUS locale. You can read more information on the project page.",
        type = "description",
        fontSize = "large"
    }
}

function Changelog:OnInitialize()
    self:Parse()

    Config:Register("Changelog", options, 0)
end

function Changelog:Parse()
    local i = 2
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