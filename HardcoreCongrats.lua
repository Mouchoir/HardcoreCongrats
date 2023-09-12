-- Database
if not HardcoreCongratsDB then
    HardcoreCongratsDB = {
    selectedMessageIndex = 1,  -- Default to the first message
    isRandom = false,          -- Default to not random
    serverMessage = "Awaiting for someone to reach level 60..." -- Default server message
}
end

local button
local congratulatedPlayers = {} -- Store players that have already been congratulated
local lastPlayer -- This variable will store the name of the last player to reach level 60

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

local serverMessageTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
serverMessageTitle:SetPoint("TOPLEFT", randomCheckbox, "BOTTOMLEFT", 0, -20)
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

-- Function to get a message							
local function getCongratsMessage()
    if randomCheckbox:GetChecked() then
        return congratsMessages[math.random(1, #congratsMessages)]
    else
        return selectedMessage
    end
end
  

-- Update the sendCongratulation function to use the chosen message																   
local function sendCongratulation(playerName)
    if congratulatedPlayers[playerName] then
        DEFAULT_CHAT_FRAME:AddMessage("You have already congratulated this player.")
        return
    end
    local message = getCongratsMessage()
    SendChatMessage(message, "WHISPER", nil, playerName)
    congratulatedPlayers[playerName] = true
end


-- Event handling function						  
local function onEvent(self, event, msg)
    -- START TEST BUTTON LOGIC: This line is specifically for the test button and can be removed later.
    DEFAULT_CHAT_FRAME:AddMessage("Received server message (Test Mode): " .. msg)
    -- END TEST BUTTON LOGIC

    local localeMessage = HardcoreCongratsLocalization[GetLocale()].alert:gsub(" ", " ")  -- both are non-breaking spaces    
    local playerName = string.match(msg, HardcoreCongratsLocalization[GetLocale()].alert)
    if playerName then
        -- START TEST BUTTON LOGIC: This line is specifically for the test button and can be removed later.
        DEFAULT_CHAT_FRAME:AddMessage("Extracted Player Name (Test Mode): " .. playerName)
        -- END TEST BUTTON LOGIC

        lastPlayer = playerName
        button:Show()
        localeOutput:SetText(msg)  -- Update the EditBox with the extracted server message
        HardcoreCongratsDB.serverMessage = msg;  -- Save the server message
    else
        localeOutput:SetText("Awaiting for someone to reach level 60...")  -- Reset to the placeholder text if not the expected message
    end
end


-- Button to send the congratulation									
button = CreateFrame("Button", "HardcoreCongratsButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("CENTER", UIParent, "CENTER")
button:SetSize(150, 30)
button:SetText("Congratulate!")
button:Hide()
button:SetScript("OnClick", function() 
    if lastPlayer then
        sendCongratulation(lastPlayer)
        button:Hide() -- Hide the button after clicking
    end
end)


-- Register for the chat message event									  
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:SetScript("OnEvent", onEvent)


-- Now, let's define the uncheckAllExcept function
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
end)

-- END OF TEST BUTTON LOGIC
