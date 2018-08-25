local L = LibStub("AceLocale-3.0"):NewLocale("Grindon_Default", "enUS", true)

L["PluginName"] = "Default"
L["SegmentStarted"] = "Please stop segment before turning on/off quality filters"
L["Header"] = "Include items"

L.Filter = {
    Quality = {
        [1] = "Poor",
        [2] = "Common",
        [3] = "Uncommon",
        [4] = "Rare",
        [5] = "Epic",
        [6] = "Legendary"
    }
}