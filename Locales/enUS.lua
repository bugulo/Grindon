local L = LibStub("AceLocale-3.0"):NewLocale("Grindon", "enUS", true)

L.General = {
    ["SegmentAlreadyStarted"] = "Segment already started",
    ["SegmentNotStarted"] = "Segment not started",
    ["SegmentStarted"] = "Segment started",
    ["SegmentStopped"] = "Segment stopped",
    ["ProfileChanged"] = "Segment was stopped due to profile change"
}

L.Core = {
    ["ConfigName"] = "General",
    ["Notice"] = "Notice",
    ["NoticeContent"] = "Please keep in mind that Grindon is in an early stage of development. Although core parts of Grindon are done, there are not many plugins right now and customization of specific features is weak as of now. Grindon is currently localized only into enUS locale. You can read more information on the project page.",
    ["Header"] = "General Options",
    ["GroupLoot"] = "Enable group loot"
}

L.Config = {
    ["StartSegment"] = "Start segment",
    ["StopSegment"] = "Stop segment"
}

L.Plugin = {
    ["ConfigName"] = "Plugins",
    ["SegmentStarted"] = "Please stop segment before turning on/off new modules"
}

L.Widget = {
    ["ConfigName"] = "Widget",
    ["ToggleWidget"] = "Toggle widget",
    ["ResetWidget"] = "Reset widget",
    ["Header"] = "Widget Options",
    ["LockMove"] = "Lock frame moving",
    ["LockSize"] = "Lock frame sizing",
    ["Frequency"] = "Enable frequency",
    ["Title"] = "Grindon segment",
    ["Scale"] = "Scale",
    ["HeaderColor"] = "Header background",
    ["HeaderTextColor"] = "Header text color",
    ["ContentColor"] = "Content background"
}

L.History = {
    ["ConfigName"] = "History",
}