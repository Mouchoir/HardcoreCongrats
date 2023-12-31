-- List of congratulatory messages
local congratsMessages = {
    "GG!", "Well done!", "Yeah you're 60! o7", "w00t <3",
    "Another hero survived ;-)"
}

local messageTypeEnum = {}
messageTypeEnum.SELECTED = 1
messageTypeEnum.RANDOM = 2
messageTypeEnum.CUSTOM = 3
messageTypeEnum.WHISPER = 4

local function resetDB()
    HardcoreCongratsDB = {
        selectedMessage = congratsMessages[1],
        customMessage = HardcoreCongratsLocalization[GetLocale()]["Custom message"] or
            "Type your custom message here",
        messageType = messageTypeEnum.SELECTED,
        serverMessage = HardcoreCongratsLocalization[GetLocale()]["Awaiting for someone to reach level 60..."] or
            "Awaiting for someone to reach level 60...",
        memoryDuration = 10, -- Default to 10 seconds
        dragFramePosition = {"CENTER", UIParent, "CENTER", 0, 0},
        instructionShown = true
    }
end

-- Database
if not HardcoreCongratsDB then resetDB() end

-- Start of debug function
local function isDebug() return _G["HardcoreCongratsDebugButton"]:IsVisible() end

local button
local pendingPlayers = {} -- Store players that will be congratulated
local lastPlayer -- This variable will store the name of the last player to reach level 60
local playerNameLabel

-- Option tab					  
local optionTab = CreateFrame("Frame", "HardcoreCongratsOptionTab",
                              InterfaceOptionsFramePanelContainer)
optionTab.name = "HardcoreCongrats"
optionTab:SetAllPoints(InterfaceOptionsFramePanelContainer);
optionTab:SetSize(InterfaceOptionsFramePanelContainer:GetWidth(),
                  InterfaceOptionsFramePanelContainer:GetHeight());
InterfaceOptions_AddCategory(optionTab)

-- ScrollFrame
optionTab.scrollframe = CreateFrame("ScrollFrame",
                                    "HardcoreCongratsScrollframe", optionTab,
                                    "UIPanelScrollFrameTemplate");
-- optionTab.scrollchild = CreateFrame("Frame");

local scrollbarName = optionTab.scrollframe:GetName()
optionTab.scrollbar = _G[scrollbarName .. "ScrollBar"];
optionTab.scrollupbutton = _G[scrollbarName .. "ScrollBarScrollUpButton"];
optionTab.scrolldownbutton = _G[scrollbarName .. "ScrollBarScrollDownButton"];

optionTab.scrollupbutton:ClearAllPoints();
optionTab.scrollupbutton:SetPoint("TOPRIGHT", optionTab.scrollframe, "TOPRIGHT",
                                  -2, -2);

optionTab.scrolldownbutton:ClearAllPoints();
optionTab.scrolldownbutton:SetPoint("BOTTOMRIGHT", optionTab.scrollframe,
                                    "BOTTOMRIGHT", -2, 2);

optionTab.scrollbar:ClearAllPoints();
optionTab.scrollbar:SetPoint("TOP", optionTab.scrollupbutton, "BOTTOM", 0, -2);
optionTab.scrollbar:SetPoint("BOTTOM", optionTab.scrolldownbutton, "TOP", 0, 2);

optionTab.scrollframe:SetAllPoints(optionTab);

-- Configuration panel					  
local panel = CreateFrame("Frame", "HardcoreCongratsConfigPanel", optionTab)
optionTab.scrollframe:SetScrollChild(panel);
panel:SetAllPoints(optionTab.scrollframe);

-- Create FontString for Detected Locale										
local detectedLocaleLabel = panel:CreateFontString(nil, "ARTWORK",
                                                   "GameFontNormal")
detectedLocaleLabel:SetPoint("TOPLEFT", 16, -16)
detectedLocaleLabel:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Detected Locale"] or
        "Detected Locale:")

local detectedLocaleValue = panel:CreateFontString(
                                "HardcoreCongratsConfigPanelDetectedLocale",
                                "ARTWORK", "GameFontWhite")
detectedLocaleValue:SetPoint("TOPLEFT", detectedLocaleLabel, "BOTTOMLEFT", 0,
                             -10)

-- Create FontString for Last Player									
local lastPlayerLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lastPlayerLabel:SetPoint("TOPLEFT", detectedLocaleValue, "BOTTOMLEFT", 0, -20)
lastPlayerLabel:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Last player to reach 60"] or
        "Last player to reach 60:")

local lastPlayerValue = panel:CreateFontString(
                            "HardcoreCongratsConfigPanelLastPlayer", "ARTWORK",
                            "GameFontWhite")
lastPlayerValue:SetPoint("TOPLEFT", lastPlayerLabel, "BOTTOMLEFT", 0, -10)

-- Add titles			 
local messageTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
messageTitle:SetPoint("TOPLEFT", lastPlayerValue, "BOTTOMLEFT", 0, -20)
messageTitle:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Choose a congratulation message"] or
        "Choose a congratulation message:")

local randomTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
randomTitle:SetPoint("TOPLEFT", messageTitle, "BOTTOMLEFT", 0,
                     -22 * (#congratsMessages + 1) + 9)
randomTitle:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Pick one at random"] or
        "Pick one at random:")

local randomCheckbox = CreateFrame("CheckButton",
                                   "HardcoreCongratsCheckboxRandom", panel,
                                   "ChatConfigCheckButtonTemplate")
randomCheckbox:SetPoint("TOPLEFT", randomTitle, "BOTTOMLEFT", 0, -10)
randomCheckbox.tooltip =
    HardcoreCongratsLocalization[GetLocale()]["Randomly pick a message"] or
        "Randomly pick a message"
getglobal(randomCheckbox:GetName() .. 'Text'):SetText(
    HardcoreCongratsLocalization[GetLocale()]["Random"] or "Random")
getglobal(randomCheckbox:GetName() .. 'Text'):SetPoint("LEFT", randomCheckbox,
                                                       "RIGHT", 5, 0)

local customizeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
customizeTitle:SetPoint("TOPLEFT", randomCheckbox, "BOTTOMLEFT", 0, -20)
customizeTitle:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Customize text"] or
        "Define a customized text to be sent")

-- Checkbox for Custom Message
local customMessageCheckbox = CreateFrame("CheckButton",
                                          "HardcoreCongratsCustomMessageCheckbox",
                                          panel, "ChatConfigCheckButtonTemplate")
customMessageCheckbox:SetHitRectInsets(0, 0, 0, 0)
customMessageCheckbox:SetPoint("TOPLEFT", customizeTitle, "BOTTOMLEFT", 0, -10)

-- Textbox (EditBox) for Custom Message
local customMessageEditBox = CreateFrame("EditBox",
                                         "HardcoreCongratsCustomMessageEditBox",
                                         panel, "InputBoxTemplate")
customMessageEditBox:SetPoint("LEFT", customMessageCheckbox, "RIGHT", 10, 0) -- This positions it to the right of the checkbox
customMessageEditBox:SetSize(400, 30) -- Adjust dimensions as necessary
customMessageEditBox:SetAutoFocus(false)
customMessageEditBox:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Custom message"] or
        "Type your custom message here")
customMessageEditBox:SetFrameStrata("HIGH")
customMessageEditBox:SetScript("OnEscapePressed",
                               function(self) self:ClearFocus() end)

customMessageEditBox:SetScript("OnTextChanged", function(self)
    HardcoreCongratsDB.customMessage = self:GetText()
end)

customMessageEditBox:SetScript("OnEditFocusLost", function(self)
    HardcoreCongratsDB.customMessage = self:GetText()
end)

-- Checkbox for Only Open Whisper
local openWhisperCheckbox = CreateFrame("CheckButton",
                                        "HardcoreCongratsOpenWhisperCheckbox",
                                        panel, "ChatConfigCheckButtonTemplate")
openWhisperCheckbox:SetPoint("TOPLEFT", customMessageCheckbox, "BOTTOMLEFT", 0,
                             0)
getglobal(openWhisperCheckbox:GetName() .. 'Text'):SetText(
    HardcoreCongratsLocalization[GetLocale()]["Open whisper"] or
        "Whisper to player (nothing is sent)")
getglobal(openWhisperCheckbox:GetName() .. 'Text'):SetPoint("LEFT",
                                                            openWhisperCheckbox,
                                                            "RIGHT", 5, 0)

local rememberTimeTitle = panel:CreateFontString(nil, "ARTWORK",
                                                 "GameFontNormal")
rememberTimeTitle:SetPoint("TOPLEFT", openWhisperCheckbox, "BOTTOMLEFT", 0, -20)
rememberTimeTitle:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Remember"] or
        "Remember a player for:")

-- Dropdown for memory duration
local memoryDurations = {5, 10, 30, 60, 120, 300} -- Durations in seconds
local memoryDurationDropdown = CreateFrame("Frame",
                                           "HardcoreCongratsMemoryDurationDropdown",
                                           panel, "UIDropDownMenuTemplate")
memoryDurationDropdown:SetPoint("TOPLEFT", rememberTimeTitle, "BOTTOMLEFT", -16,
                                -10)
UIDropDownMenu_SetWidth(memoryDurationDropdown, 150)
UIDropDownMenu_SetText(memoryDurationDropdown,
                       (HardcoreCongratsDB.memoryDuration) .. " " ..
                           (HardcoreCongratsLocalization[GetLocale()]["Seconds"] or
                               "sec."))

UIDropDownMenu_Initialize(memoryDurationDropdown, function(self, level)
    for _, duration in ipairs(memoryDurations) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = (duration) .. " " ..
                        (HardcoreCongratsLocalization[GetLocale()]["Seconds"] or
                            "sec.")
        info.value = duration
        info.func = function()
            HardcoreCongratsDB.memoryDuration = duration
            UIDropDownMenu_SetText(memoryDurationDropdown, info.text)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local serverMessageTitle = panel:CreateFontString(nil, "ARTWORK",
                                                  "GameFontNormal")
serverMessageTitle:SetPoint("TOPLEFT", memoryDurationDropdown, "BOTTOMLEFT", 16,
                            -20)
serverMessageTitle:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Event server message"] or
        "Event server message")

-- Create an InputBox
local localeOutput = CreateFrame("EditBox", "HardcoreCongratsLocaleOutput",
                                 panel, "InputBoxTemplate")
localeOutput:SetPoint("TOPLEFT", serverMessageTitle, "BOTTOMLEFT", 0, -10)
localeOutput:SetSize(400, 100)
localeOutput:SetMultiLine(true)
localeOutput:SetAutoFocus(false)
localeOutput:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Awaiting for someone to reach level 60..."] or
        "Awaiting for someone to reach level 60...")
localeOutput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

-- Create FontString for Localization Note
local localizationNoteLabel = panel:CreateFontString(nil, "ARTWORK",
                                                     "GameFontNormalSmall")
localizationNoteLabel:SetWidth(localeOutput:GetWidth()) -- Set width to match the width of the localeOutput textbox
localizationNoteLabel:SetWordWrap(true) -- Enable word wrapping
localizationNoteLabel:SetJustifyH("LEFT") -- Align text to the left
localizationNoteLabel:SetPoint("TOPLEFT", localeOutput, "BOTTOMLEFT", 0, -20)
localizationNoteLabel:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Localization Note"] or
        "Copy/paste this to create the localization file in your own language since Blizzard sometimes uses special characters such as non-breakable spaces. Then replace the character's name with (.-).")

-- Create a frame to group the button and the player name label
local dragFrame = CreateFrame("Frame", "HardcoreCongratsDragFrame", UIParent)
dragFrame:SetSize(150, 60) -- The combined size of the button and the name label
dragFrame:SetPoint("CENTER", UIParent, "CENTER") -- Initial position
dragFrame:Hide()

-- Make the frame movable
dragFrame:SetMovable(true)
-- Make the dragFrame receive mouse events
dragFrame:EnableMouse(true)

dragFrame:SetFrameStrata("HIGH") -- This ensures the dragFrame is above the button
dragFrame:RegisterForDrag("LeftButton")
dragFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then self:StartMoving() end
end)

dragFrame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
    -- Save the position for future sessions
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    HardcoreCongratsDB.dragFramePosition = {point, relativePoint, xOfs, yOfs}
end)

dragFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save the position for future sessions
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    HardcoreCongratsDB.dragFramePosition = {point, relativePoint, xOfs, yOfs}
end)

-- Create playerNameLabel
playerNameLabel = dragFrame:CreateFontString(nil, "OVERLAY",
                                             "GameFontNormalLarge")
playerNameLabel:SetPoint("CENTER", dragFrame, "TOP", 0, 5)
playerNameLabel:EnableMouse(true)
playerNameLabel:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then
        self:GetParent():StartMoving()
    end
end)
playerNameLabel:SetScript("OnMouseUp", function(self)
    self:GetParent():StopMovingOrSizing()
    -- Save the position for future sessions
    local point, _, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
    HardcoreCongratsDB.dragFramePosition = {point, relativePoint, xOfs, yOfs}
end)

-- Restore the saved position of the drag frame
if HardcoreCongratsDB.dragFramePosition then
    local point, relativePoint, xOfs, yOfs = unpack(
                                                 HardcoreCongratsDB.dragFramePosition)
    dragFrame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
end

-- Reset all options to default
local function resetSettingsToDefault()
    resetDB()
    -- Reset the position of the drag frame
    dragFrame:ClearAllPoints()
    dragFrame:SetPoint(unpack(HardcoreCongratsDB.dragFramePosition))
    -- Ensure the dragFrame's position in the database is updated
    local point, _, relativePoint, xOfs, yOfs = dragFrame:GetPoint()
    HardcoreCongratsDB.dragFramePosition = {point, relativePoint, xOfs, yOfs}

    DEFAULT_CHAT_FRAME:AddMessage(
        HardcoreCongratsLocalization[GetLocale()]["Reset information"] or
            "HardcoreCongrats settings have been reset to default.")
end

-- Instructions under the first congratulate button
local instructionLabel = dragFrame:CreateFontString(nil, "OVERLAY",
                                                    "GameFontNormalSmall")
instructionLabel:SetPoint("CENTER", dragFrame, "CENTER", 0, -35)
instructionLabel:SetText(
    HardcoreCongratsLocalization[GetLocale()]["Shift+click instruction"] or
        "Shift+click to move\nAlt or Ctrl+click to remove player")
instructionLabel:Hide()

local function getCongratsMessage()
    if HardcoreCongratsDB.messageType == messageTypeEnum.RANDOM then
        return congratsMessages[math.random(#congratsMessages)]
    elseif HardcoreCongratsDB.messageType == messageTypeEnum.SELECTED then
        return HardcoreCongratsDB.selectedMessage
    elseif HardcoreCongratsDB.messageType == messageTypeEnum.CUSTOM then
        return HardcoreCongratsDB.customMessage
    end
end

local function updateButtonAndNameLabelVisibility()
    if #pendingPlayers > 0 then
        lastPlayer = pendingPlayers[#pendingPlayers].name
        playerNameLabel:SetText(lastPlayer)
        dragFrame:Show()

        -- Check if we've shown the instruction before
        if HardcoreCongratsDB.instructionShown then
            instructionLabel:Show()
        else
            instructionLabel:Hide()
        end
    else
        playerNameLabel:SetText("")
        dragFrame:Hide()
    end
end

local function prunePendingPlayers()
    local currentTime = time()
    for i = #pendingPlayers, 1, -1 do -- Looping backwards to safely remove elements
        local playerInfo = pendingPlayers[i]
        if currentTime - playerInfo.timestamp >
            HardcoreCongratsDB.memoryDuration then
            table.remove(pendingPlayers, i)
        end
    end
end

local function sendCongratulation(playerName)
    if HardcoreCongratsDB.messageType ~= messageTypeEnum.WHISPER then
        local message = getCongratsMessage()
        SendChatMessage(message, "WHISPER", nil, playerName)
        if isDebug() then
            DEFAULT_CHAT_FRAME:AddMessage("Message sent: " .. message)
        end
    else
        ChatFrame_OpenChat("/whisper " .. playerName .. " ")
    end
end

local function onEvent(self, event, msg)

    local localeMessage = HardcoreCongratsLocalization[GetLocale()].alert
    local playerName = string.match(msg, localeMessage)

    if playerName and playerName ~= "" then
        table.insert(pendingPlayers, {name = playerName, timestamp = time()})
        updateButtonAndNameLabelVisibility()
        localeOutput:SetText(msg) -- Update the EditBox with the extracted server message
        HardcoreCongratsDB.serverMessage = msg
    else
        return
    end
end

-- Button to send the congratulation									
button = CreateFrame("Button", "HardcoreCongratsButton", dragFrame,
                     "UIPanelButtonTemplate")
button:SetPoint("CENTER", dragFrame, "CENTER")
button:SetSize(150, 30)
button:SetText(HardcoreCongratsLocalization[GetLocale()]["Congratulate"] or
                   "Congratulate!")
button:Show()
button:SetScript("OnClick", function(self, buttonName)
    if #pendingPlayers > 0 then
        lastPlayer = pendingPlayers[#pendingPlayers].name
        if buttonName == "LeftButton" then
            -- Alt+Click or Ctrl+Click removes the player from the list of players to congratulate
            if IsControlKeyDown() or IsAltKeyDown() then
                table.remove(pendingPlayers)
                -- Leftclick congratulates the player and removes his character's name
            else
                sendCongratulation(lastPlayer)
                table.remove(pendingPlayers)
            end
        end
        updateButtonAndNameLabelVisibility()
        HardcoreCongratsDB.instructionShown = false
    end
end)

-- Register for the chat message event									  
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:SetScript("OnEvent", onEvent)

local function uncheckAllExcept(exceptIndex, unsetRandomCheckbox,
                                unsetCustomCheckbox, unsetWhisperCheckbox)
    for i = 1, #congratsMessages + 1 do
        if i ~= exceptIndex then
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then checkbox:SetChecked(false) end
        end
    end
    if unsetRandomCheckbox then randomCheckbox:SetChecked(false) end
    if unsetCustomCheckbox then
        HardcoreCongratsCustomMessageCheckbox:SetChecked(false)
    end
    if unsetWhisperCheckbox then
        HardcoreCongratsOpenWhisperCheckbox:SetChecked(false)
    end
end

-- Creating Checkboxes
for i, message in ipairs(congratsMessages) do
    local checkbox = CreateFrame("CheckButton", "HardcoreCongratsCheckbox" .. i,
                                 panel, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", messageTitle, "BOTTOMLEFT", 0, (-19 * i) + 9)
    checkbox.tooltip = message
    getglobal(checkbox:GetName() .. 'Text'):SetText(message)
    getglobal(checkbox:GetName() .. 'Text'):SetPoint("LEFT", checkbox, "RIGHT",
                                                     5, 0)

    checkbox.wasChecked = false
    checkbox:SetScript("OnMouseDown",
                       function(self) self.wasChecked = self:GetChecked() end)

    checkbox:SetScript("OnClick", function(self)
        if self.wasChecked then
            self:SetChecked(false)
            _G["HardcoreCongratsCheckbox1"]:SetChecked(true)
            HardcoreCongratsDB.selectedMessage = congratsMessages[1]
        else
            uncheckAllExcept(i, true, true, true) -- Also uncheck the other checkboxes
            HardcoreCongratsDB.selectedMessage = self.tooltip
        end
        HardcoreCongratsDB.messageType = messageTypeEnum.SELECTED
    end)

    -- Check the checkbox for "GG!" by default
    if i == 1 then checkbox:SetChecked(true) end
end

-- Adapting the position of the next UI element after the checkboxes
randomTitle:SetPoint("TOPLEFT",
                     _G["HardcoreCongratsCheckbox" .. (#congratsMessages)],
                     "BOTTOMLEFT", 0, -10)

-- Random checkbox unchecking
randomCheckbox:SetScript("OnClick", function(self)
    if self:GetChecked() then
        uncheckAllExcept(#congratsMessages + 1, false, true, true) -- Uncheck all the message checkboxes
        HardcoreCongratsDB.messageType = messageTypeEnum.RANDOM
    else
        -- If user tries to uncheck the "Random" checkbox, recheck the "GG!" checkbox
        HardcoreCongratsDB.selectedMessage = congratsMessages[1]
        _G["HardcoreCongratsCheckbox1"]:SetChecked(true)
        HardcoreCongratsDB.messageType = messageTypeEnum.SELECTED
    end
end)

-- Custom checkbox unchecking
customMessageCheckbox:SetScript("OnClick", function(self)
    if self:GetChecked() then
        uncheckAllExcept(#congratsMessages + 1, true, false, true) -- Uncheck all the message checkboxes
        HardcoreCongratsDB.messageType = messageTypeEnum.CUSTOM
    else
        -- If user tries to uncheck the "Random" checkbox, recheck the "GG!" checkbox
        HardcoreCongratsDB.selectedMessage = congratsMessages[1]
        _G["HardcoreCongratsCheckbox1"]:SetChecked(true)
        HardcoreCongratsDB.messageType = messageTypeEnum.SELECTED
    end
end)

-- Whisper checkbox unchecking
openWhisperCheckbox:SetScript("OnClick", function(self)
    if self:GetChecked() then
        uncheckAllExcept(#congratsMessages + 1, true, true, false) -- Uncheck all the message checkboxes
        HardcoreCongratsDB.messageType = messageTypeEnum.WHISPER
    else
        -- If user tries to uncheck the "Random" checkbox, recheck the "GG!" checkbox
        HardcoreCongratsDB.selectedMessage = congratsMessages[1]
        _G["HardcoreCongratsCheckbox1"]:SetChecked(true)
        HardcoreCongratsDB.messageType = messageTypeEnum.SELECTED
    end
end)

-- Set the checkbox state based on the saved setting
for i = 1, #congratsMessages do
    local checkbox = _G["HardcoreCongratsCheckbox" .. i]
    if checkbox then
        checkbox:SetChecked(checkbox.tooltip ==
                                HardcoreCongratsDB.selectedMessage)
    end
end

-- Set the random check based on the saved settings
randomCheckbox:SetChecked(HardcoreCongratsDB.messageType ==
                              messageTypeEnum.RANDOM)

-- Calculating panel height
local panelHeight = detectedLocaleLabel:GetTop() -
                        localizationNoteLabel:GetBottom() + 30 -- Added a margin of 30 for safety
panel:SetSize(optionTab.scrollframe:GetWidth(), panelHeight);
if panel:GetHeight() <= optionTab:GetHeight() then optionTab.scrollbar:Hide() end

-- Set the EditBox text based on the saved server message
localeOutput:SetText(HardcoreCongratsDB.serverMessage)

panel:SetScript("OnShow", function()
    -- Update locale values
    detectedLocaleValue:SetText(GetLocale())
    lastPlayerValue:SetText(lastPlayer or "None")

    -- Update the checkboxes based on the saved state
    if HardcoreCongratsDB.messageType == messageTypeEnum.RANDOM then
        randomCheckbox:SetChecked(true)
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false) -- Uncheck all message checkboxes if random is selected
            end
        end
        openWhisperCheckbox:SetChecked(false)
        customMessageCheckbox:SetChecked(false)
    elseif HardcoreCongratsDB.messageType == messageTypeEnum.WHISPER then
        openWhisperCheckbox:SetChecked(true)
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false) -- Uncheck all message checkboxes if random is selected
            end
        end
        randomCheckbox:SetChecked(false)
        customMessageCheckbox:SetChecked(false)

    elseif HardcoreCongratsDB.messageType == messageTypeEnum.CUSTOM then
        customMessageCheckbox:SetChecked(true)
        customMessageEditBox:SetText(HardcoreCongratsDB.customMessage)
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false) -- Uncheck all message checkboxes if random is selected
            end
        end
        randomCheckbox:SetChecked(false)
        openWhisperCheckbox:SetChecked(false)
    elseif HardcoreCongratsDB.messageType == messageTypeEnum.SELECTED then
        randomCheckbox:SetChecked(false)
        openWhisperCheckbox:SetChecked(false)
        customMessageCheckbox:SetChecked(false)
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(checkbox.tooltip ==
                                        HardcoreCongratsDB.selectedMessage)
            end
        end
    end

    -- Update dropdown list
    UIDropDownMenu_SetText(memoryDurationDropdown,
                           (HardcoreCongratsDB.memoryDuration) .. " " ..
                               (HardcoreCongratsLocalization[GetLocale()]["Seconds"] or
                                   "sec."))

    -- Update the EditBox text based on the saved server message
    localeOutput:SetText(HardcoreCongratsDB.serverMessage)
end)

-- Call prunePendingPlayers periodically, e.g., every 10 seconds
C_Timer.NewTicker(10, function()
    prunePendingPlayers()
    updateButtonAndNameLabelVisibility()
end)

-- START OF DEBUG BUTTON LOGIC: This section is meant for debugging
local function contains(table, value)
    for _, v in ipairs(table) do if v.name == value then return true end end

    return false
end
local function getRandomPlayer()
    -- Returns a random player name								  
    local names = {
        "Aelzaeoria", "Bromazeali", "Thandazeazearel", "Elowazeazynn",
        "Kazeazordric", "Maeazeazlis", "Taazelindra", "Gaazeromlor",
        "Laelazeith", "Nordazeran", "Vaelazeora", "Thoazerdric", "Elaazendra",
        "Rhalgazear", "Loriazenell"
    }
    return names[math.random(#names)]
end
local function getUniqueRandomPlayer()
    local playerName = getRandomPlayer()

    while contains(pendingPlayers, playerName) do
        playerName = getRandomPlayer()
    end

    return playerName
end

-- DEBUG Button Creation
local debugButton = CreateFrame("Button", "HardcoreCongratsDebugButton",
                                UIParent, "UIPanelButtonTemplate")
debugButton:SetSize(100, 30)
debugButton:SetPoint("CENTER", 0, 350)
debugButton:SetText("DEBUG")
debugButton:Hide()
debugButton:SetScript("OnClick", function()
    -- Get random player name                            
    local playerName = getUniqueRandomPlayer()
    -- Format mock event based on the locale
    local msg = playerName ..
                    HardcoreCongratsLocalization[GetLocale()].alert:sub(5)
    -- Trigger onEvent() with mock event                                       
    onEvent(nil, nil, msg)
end)
-- END OF DEBUG BUTTON LOGIC

-- START OF THE SLASH COMMAND
-- Register a slash command
SLASH_HARDWARECONGRATS1 = "/hccongrats"
SlashCmdList["HARDWARECONGRATS"] = function(msg)
    if msg == "list" then
        -- Check if there are any players in the list
        if #pendingPlayers == 0 then
            DEFAULT_CHAT_FRAME:AddMessage(
                HardcoreCongratsLocalization[GetLocale()]["No players awaiting"] or
                    "No players are awaiting congratulations.")
            return
        end
        -- Display each player that is awaiting congratulations
        DEFAULT_CHAT_FRAME:AddMessage(
            HardcoreCongratsLocalization[GetLocale()]["Players awaiting"] or
                "Players awaiting congratulations:")
        for _, playerInfo in ipairs(pendingPlayers) do
            DEFAULT_CHAT_FRAME:AddMessage(playerInfo.name)
        end
    elseif msg == "reset" then
        resetSettingsToDefault()
        InterfaceOptionsFrame:Hide() -- This line ensures the options panel doesn't open
    elseif msg == "debug" then
        if debugButton:IsShown() then
            debugButton:Hide()
        else
            debugButton:Show()
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage(
            HardcoreCongratsLocalization[GetLocale()]["hccongrats debug button"] or
                "/hccongrats debug - Displays the debug button.")
        DEFAULT_CHAT_FRAME:AddMessage(
            HardcoreCongratsLocalization[GetLocale()]["hccongrats list instruction"] or
                "/hccongrats list - Displays list of players awaiting congratulations.")
        DEFAULT_CHAT_FRAME:AddMessage(
            HardcoreCongratsLocalization[GetLocale()]["hccongrats reset instruction"] or
                "/hccongrats reset - Resets the addon to default options.")
        DEFAULT_CHAT_FRAME:AddMessage(
            HardcoreCongratsLocalization[GetLocale()]["Hold shift instruction"] or
                "Hold shift to move the button.")
        DEFAULT_CHAT_FRAME:AddMessage(
            HardcoreCongratsLocalization[GetLocale()]["Alt or Ctrl + click instruction"] or
                "Alt or Ctrl + click on the button to remove the player without congratulating.")

    end
end

-- END OF THE SLASH COMMAND

