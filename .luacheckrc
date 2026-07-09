-- luacheck configuration for the HardcoreCongrats WoW Classic addon.
-- Run:  luacheck .
std = "lua51"

-- Addon-local globals that are intentionally shared or written.
globals = {
    "HardcoreCongratsDB",
    "HardcoreCongratsLocalization",
    "SLASH_HARDWARECONGRATS1",
    "SlashCmdList",           -- the addon registers its handler here
    -- Named frames created via CreateFrame auto-create a matching _G entry;
    -- luacheck can't see that, so declare the ones referenced by name.
    "HardcoreCongratsCustomMessageCheckbox",
    "HardcoreCongratsOpenWhisperCheckbox",
}

-- WoW client API surface used by this addon (read-only globals).
read_globals = {
    -- Core API
    "CreateFrame", "GetLocale", "UIParent", "time",
    "SendChatMessage", "ChatFrame_OpenChat", "DEFAULT_CHAT_FRAME",
    "IsShiftKeyDown", "IsControlKeyDown", "IsAltKeyDown",
    "getglobal", "unpack",
    -- Settings / Interface options
    "Settings", "InterfaceOptions_AddCategory", "InterfaceOptionsFrame",
    -- Dropdown menu API
    "UIDropDownMenu_SetWidth", "UIDropDownMenu_SetText",
    "UIDropDownMenu_Initialize", "UIDropDownMenu_CreateInfo",
    "UIDropDownMenu_AddButton",
    -- Timers
    "C_Timer",
}

-- The addon is a single large file with many long UI setup lines; don't flag
-- line length, and allow the mixed-case slash-command globals.
max_line_length = false
