-- Database
if not HardcoreCongratsDB then
    HardcoreCongratsDB = {
        selectedMessageIndex = 1,
        isRandom = false,
        serverMessage = "Awaiting for someone to reach level 60...",
        memoryDuration = 60 -- Default to 1 minute (600 seconds)
    }
end

local button
local pendingPlayers = {} -- Store players that will be congratulated
local lastPlayer -- This variable will store the name of the last player to reach level 60
local playerNameLabel

-- List of congratulatory messages
local congratsMessages = {
    "GG!",
    "Well done!",
    "Yeah you're 60!!",
    "w00t",
    "Another hero survived"
}

local selectedMessage = congratsMessages[1] -- Default to first "GG!"

-- Configuration panel					  
local panel = CreateFrame("Frame", "HardcoreCongratsConfigPanel", InterfaceOptionsFramePanelContainer)
panel.name = "HardcoreCongrats"
InterfaceOptions_AddCategory(panel)

-- Create FontString for Detected Locale										
local detectedLocaleLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
detectedLocaleLabel:SetPoint("TOPLEFT", 16, -16)
detectedLocaleLabel:SetText(HardcoreCongratsLocalization[GetLocale()]["Detected Locale"] or "Detected Locale:")

local detectedLocaleValue = panel:CreateFontString("HardcoreCongratsConfigPanelDetectedLocale", "ARTWORK", "GameFontWhite")
detectedLocaleValue:SetPoint("TOPLEFT", detectedLocaleLabel, "BOTTOMLEFT", 0, -10)

-- Create FontString for Last Player									
local lastPlayerLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lastPlayerLabel:SetPoint("TOPLEFT", detectedLocaleValue, "BOTTOMLEFT", 0, -20)
lastPlayerLabel:SetText(HardcoreCongratsLocalization[GetLocale()]["Last player to reach 60"] or "Last player to reach 60:")

local lastPlayerValue = panel:CreateFontString("HardcoreCongratsConfigPanelLastPlayer", "ARTWORK", "GameFontWhite")
lastPlayerValue:SetPoint("TOPLEFT", lastPlayerLabel, "BOTTOMLEFT", 0, -10)

-- Add titles			 
local messageTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
messageTitle:SetPoint("TOPLEFT", lastPlayerValue, "BOTTOMLEFT", 0, -20)
messageTitle:SetText(HardcoreCongratsLocalization[GetLocale()]["Choose a congratulation message"] or "Choose a congratulation message:")

local randomTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
randomTitle:SetPoint("TOPLEFT", messageTitle, "BOTTOMLEFT", 0, -22 * (#congratsMessages + 1))
randomTitle:SetText(HardcoreCongratsLocalization[GetLocale()]["Pick one at random"] or "Pick one at random:")

local randomCheckbox = CreateFrame("CheckButton", "HardcoreCongratsCheckboxRandom", panel, "ChatConfigCheckButtonTemplate")
randomCheckbox:SetPoint("TOPLEFT", randomTitle, "BOTTOMLEFT", 0, -15)
randomCheckbox.tooltip = "Randomly pick a message"
getglobal(randomCheckbox:GetName() .. 'Text'):SetText("Random")

local rememberTimeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rememberTimeTitle:SetPoint("TOPLEFT", randomCheckbox, "BOTTOMLEFT", 0, -20)
rememberTimeTitle:SetText(HardcoreCongratsLocalization[GetLocale()]["Remember"] or "Remember a player for:")

-- Dropdown for memory duration
local memoryDurations = {60, 120, 300} -- Durations in seconds
local memoryDurationDropdown = CreateFrame("Frame", "HardcoreCongratsMemoryDurationDropdown", panel, "UIDropDownMenuTemplate")
memoryDurationDropdown:SetPoint("TOPLEFT", rememberTimeTitle, "BOTTOMLEFT", -16, -30)
UIDropDownMenu_SetWidth(memoryDurationDropdown, 150)
UIDropDownMenu_SetText(memoryDurationDropdown, HardcoreCongratsDB.memoryDuration / 60 .. " minutes")

UIDropDownMenu_Initialize(memoryDurationDropdown, function(self, level)
    for _, duration in ipairs(memoryDurations) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = (duration / 60) .. " " .. (HardcoreCongratsLocalization[GetLocale()]["Minutes"] or "minutes")
        info.value = duration
        info.func = function()
            HardcoreCongratsDB.memoryDuration = duration
            UIDropDownMenu_SetText(memoryDurationDropdown, info.text)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local serverMessageTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
serverMessageTitle:SetPoint("TOPLEFT", memoryDurationDropdown, "BOTTOMLEFT", 16, -20)
serverMessageTitle:SetText(HardcoreCongratsLocalization[GetLocale()]["Event server message"] or "Event server message")

--Create an InputBox
local localeOutput = CreateFrame("EditBox", "HardcoreCongratsLocaleOutput", panel, "InputBoxTemplate")
localeOutput:SetPoint("TOPLEFT", serverMessageTitle, "BOTTOMLEFT", 0, -10)
localeOutput:SetSize(400, 100)
localeOutput:SetMultiLine(true)
localeOutput:SetAutoFocus(false)
localeOutput:SetText(HardcoreCongratsLocalization[GetLocale()]["Awaiting for someone to reach level 60..."] or "Awaiting for someone to reach level 60...")
localeOutput:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

-- Create FontString for Localization Note
local localizationNoteLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
localizationNoteLabel:SetWidth(localeOutput:GetWidth())  -- Set width to match the width of the localeOutput textbox
localizationNoteLabel:SetWordWrap(true)  -- Enable word wrapping
localizationNoteLabel:SetJustifyH("LEFT")  -- Align text to the left
localizationNoteLabel:SetPoint("TOPLEFT", localeOutput, "BOTTOMLEFT", 0, -20)
localizationNoteLabel:SetText(HardcoreCongratsLocalization[GetLocale()]["Localization Note"] or "Copy/paste this to create the localization file in your own language since Blizzard sometimes uses special characters such as non-breakable spaces. Then replace the character's name with (.-).")


local function getCongratsMessage()
    if randomCheckbox:GetChecked() then
        return congratsMessages[math.random(1, #congratsMessages)]
    else
        return selectedMessage
    end
end


local function updateButtonAndNameLabelVisibility() --Handles "Congratulate and player labed visibility
    if #pendingPlayers > 0 then
        lastPlayer = pendingPlayers[#pendingPlayers].name
        playerNameLabel:SetText(lastPlayer)  -- Set the name text
        playerNameLabel:Show()  -- Explicitly show the name label again
        button:Show()
    else
        lastPlayer = nil  -- Reset lastPlayer
        playerNameLabel:SetText("")  -- Clear the name text
        button:Hide()
        playerNameLabel:Hide()  -- Hide the name label
    end
end


local function prunependingPlayers()
    local currentTime = time()
    for i = #pendingPlayers, 1, -1 do -- Looping backwards to safely remove elements
        local playerInfo = pendingPlayers[i]
        if currentTime - playerInfo.timestamp > HardcoreCongratsDB.memoryDuration then
            DEFAULT_CHAT_FRAME:AddMessage("Player " .. playerInfo.name .. " has been removed from the list due to time exceeding.")
            table.remove(pendingPlayers, i)
        end
    end
    updateButtonAndNameLabelVisibility()
end



local function sendCongratulation(playerName)
    local playerIndexToRemove
    for index, playerInfo in ipairs(pendingPlayers) do
        if playerInfo.name == playerName then
            playerIndexToRemove = index
            break
        end
    end
    
    local message = getCongratsMessage()
    SendChatMessage(message, "WHISPER", nil, playerName)
    
    -- Remove the player from the list after congratulating them
    if playerIndexToRemove then
        table.remove(pendingPlayers, playerIndexToRemove)
        DEFAULT_CHAT_FRAME:AddMessage("Player " .. playerName .. " has been congratulated and removed from the list.")
    end
    
    -- Check if there's another player to congratulate
    updateButtonAndNameLabelVisibility()
    prunependingPlayers()
end



local function onEvent(self, event, msg)
    -- DEBUG: Print the received server message
    DEFAULT_CHAT_FRAME:AddMessage("Received server message: " .. msg)
    -- END TEST BUTTON LOGIC

    local localeMessage = HardcoreCongratsLocalization[GetLocale()].alert -- Replace non-breaking spaces with regular spaces
    local playerName = string.match(msg, localeMessage)

    if playerName then
         -- DEBUG: Print the extracted player name
         DEFAULT_CHAT_FRAME:AddMessage("Extracted Player Name: " .. playerName)
        -- END TEST BUTTON LOGIC

        local playerExists = false
        for _, playerInfo in ipairs(pendingPlayers) do
            if playerInfo.name == playerName then
                playerInfo.congratulated = true
                playerExists = true
                break
            end
        end
        
        if not playerExists then
            table.insert(pendingPlayers, {name = playerName, timestamp = time(), congratulated = false})
            updateButtonAndNameLabelVisibility()
        end        
        
        updateButtonAndNameLabelVisibility()
        
    else
         -- DEBUG: If player extraction failed, print a debug message
         DEFAULT_CHAT_FRAME:AddMessage("Failed to extract player name from server message.")
        lastPlayer = playerName
        if msg == HardcoreCongratsDB.serverMessage then
            button:Show()
            localeOutput:SetText(msg)  -- Update the EditBox with the extracted server message
            HardcoreCongratsDB.serverMessage = msg;  -- Save the server message
        else
            localeOutput:SetText("Awaiting for someone to reach level 60...")
        end
        playerNameLabel:Hide()  -- Hide the name label when the button is hidden
    end
end

-- Button to send the congratulation									
button = CreateFrame("Button", "HardcoreCongratsButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("CENTER", UIParent, "CENTER")
button:SetSize(150, 30)
button:SetText("Congratulate!")
button:Hide()
button:SetScript("OnClick", function() 
    if #pendingPlayers > 0 then
        lastPlayer = pendingPlayers[#pendingPlayers].name
        sendCongratulation(lastPlayer)
    end
end)

-- Register for the chat message event									  
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:SetScript("OnEvent", onEvent)

local function uncheckAllExcept(exceptIndex, touchRandomCheckbox)
    for i = 1, #congratsMessages + 1 do
        if i ~= exceptIndex then
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false)
            end
        end
    end
    if touchRandomCheckbox then
        randomCheckbox:SetChecked(false)
    end
end

-- Creating Checkboxes
for i, message in ipairs(congratsMessages) do
    local checkbox = CreateFrame("CheckButton", "HardcoreCongratsCheckbox" .. i, panel, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", messageTitle, "BOTTOMLEFT", 0, -19 * i)
    checkbox.tooltip = message
    getglobal(checkbox:GetName() .. 'Text'):SetText(message)

    checkbox.wasChecked = false
    checkbox:SetScript("OnMouseDown", function(self)
        self.wasChecked = self:GetChecked()
    end)
    
    checkbox:SetScript("OnClick", function(self)
        if self.wasChecked then
            self:SetChecked(false)
            _G["HardcoreCongratsCheckbox1"]:SetChecked(true)
            selectedMessage = congratsMessages[1]
            HardcoreCongratsDB.selectedMessageIndex = 1
        else
            selectedMessage = congratsMessages[i]
            uncheckAllExcept(i, true) -- Also uncheck the randomCheckbox
            HardcoreCongratsDB.selectedMessageIndex = i
        end
    end)
    
    -- Check the checkbox for "GG!" by default
    if i == 1 then
        checkbox:SetChecked(true)
    end
end

randomCheckbox:SetScript("OnClick", function(self)
    if self:GetChecked() then
        uncheckAllExcept(#congratsMessages + 1) -- Uncheck all the message checkboxes
    else
        -- If user tries to uncheck the "Random" checkbox, recheck the "GG!" checkbox
        selectedMessage = congratsMessages[1]
        _G["HardcoreCongratsCheckbox1"]:SetChecked(true)
        HardcoreCongratsDB.selectedMessageIndex = 1
    end
    HardcoreCongratsDB.isRandom = self:GetChecked()
end)

-- Set the checkbox state based on the saved setting
_G["HardcoreCongratsCheckbox" .. HardcoreCongratsDB.selectedMessageIndex]:SetChecked(true)
randomCheckbox:SetChecked(HardcoreCongratsDB.isRandom)

-- Set the EditBox text based on the saved server message
localeOutput:SetText(HardcoreCongratsDB.serverMessage)

panel:SetScript("OnShow", function()
    -- Update locale values
    detectedLocaleValue:SetText(GetLocale())
    lastPlayerValue:SetText(lastPlayer or "None")
    
    if HardcoreCongratsDB.isRandom then
        -- If random is true, ensure all other checkboxes are unchecked
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false)
            end
        end
        randomCheckbox:SetChecked(true)
    else
        -- Otherwise, only check the checkbox corresponding to the saved message index
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(i == HardcoreCongratsDB.selectedMessageIndex)
            end
        end
        randomCheckbox:SetChecked(false)
    end
    
    -- Update the EditBox text based on the saved server message
    localeOutput:SetText(HardcoreCongratsDB.serverMessage or "Awaiting for someone to reach level 60...")
end)

-- START OF TEST BUTTON LOGIC: This section is meant for testing and can be safely removed later.

-- This is meant for the test button
local function getRandomPlayer()
    -- Returns a random player name								  
    local names = {
        "Aeloria", "Bromli", "Thandrel", "Elowynn", "Kordric", 
        "Maelis", "Talindra", "Gromlor", "Laelith", "Nordran", 
        "Vaelora", "Thordric", "Elandra", "Rhalgar", "Lorinell"
    }
    return names[math.random(#names)]
end

-- Test Button Creation
local testButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
testButton:SetSize(100, 30)
testButton:SetPoint("TOPLEFT", 100, -100)
testButton:SetText("TEST!") 

-- Create a FontString above the button
playerNameLabel = button:CreateFontString(nil, "OVERLAY", "GameFontWhite")
playerNameLabel:SetPoint("BOTTOM", button, "TOP", 0, 5)  -- Position it above the button

-- Create a backdrop for the FontString
local backdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",  -- Using a default texture
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

-- Create a frame to serve as the backdrop
local backdropFrame = CreateFrame("Frame", nil, button, "BackdropTemplate")
backdropFrame:SetSize(button:GetWidth(), 30)  -- Set the size you want
backdropFrame:SetPoint("BOTTOM", button, "TOP", 0, 5)  -- Position it above the button

-- Position the playerNameLabel on top of this frame
playerNameLabel:SetPoint("CENTER", backdropFrame, "CENTER")


testButton:SetScript("OnClick", function()
    -- Get random player name                            
    local playerName = getRandomPlayer()

    -- Format mock event based on the locale
    local testEvent
    if GetLocale() == "frFR" then
        testEvent = string.format("%s a atteint le niveau 60 !", playerName)
    else
        testEvent = string.format("%s has reached level 60!", playerName)
    end

    -- Trigger onEvent() with mock event                                       
    onEvent(nil, nil, testEvent)

    -- Display all registered player names
    DEFAULT_CHAT_FRAME:AddMessage("Liste des pseudos enregistrés:")
    for _, playerInfo in ipairs(pendingPlayers) do
        DEFAULT_CHAT_FRAME:AddMessage(playerInfo.name)
    end
end)

-- Register for the chat message event									  
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:SetScript("OnEvent", onEvent)

-- Call prunependingPlayers periodically, e.g., every 10 seconds
C_Timer.NewTicker(10, prunependingPlayers)
-- END OF TEST BUTTON LOGIC

-- START OF THE SLASH COMMAND
-- Register a slash command
SLASH_HARDWARECONGRATS1 = "/hccongrats"
SlashCmdList["HARDWARECONGRATS"] = function(msg)
    if msg == "list" then
        -- Check if there are any players in the list
        if #pendingPlayers == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("No players are awaiting congratulations.")
            return
        end
        
        -- Display each player that is awaiting congratulations
        DEFAULT_CHAT_FRAME:AddMessage("Players awaiting congratulations:")
        for _, playerInfo in ipairs(pendingPlayers) do
            if not playerInfo.congratulated then
                DEFAULT_CHAT_FRAME:AddMessage(playerInfo.name)
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /hccongrats list - Displays list of players awaiting congratulations.")
    end
end
-- END OF THE SLASH COMMAND
