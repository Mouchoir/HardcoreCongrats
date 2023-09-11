local button
local lastPlayer -- This variable will store the name of the last player to reach level 60
local congratulatedPlayers = {} -- Store players that have already been congratulated

-- List of congratulatory messages
local congratsMessages = {
    "GG!",
    "Well done!",
    "Yeeeah you're 60!",
    "Another hero survived"
}

local selectedMessage = congratsMessages[1] -- Default to first "GG!"

-- TEST
if HardcoreCongratsLocalization["frFR"] then
    DEFAULT_CHAT_FRAME:AddMessage("French localization loaded.")
else
    DEFAULT_CHAT_FRAME:AddMessage("French localization NOT loaded.")
end

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

    -- Add the debug line here
    DEFAULT_CHAT_FRAME:AddMessage("Sent message: \"" .. message .. "\" to " .. playerName)
end


-- Event handling function						  
local function onEvent(self, event, msg)
    DEFAULT_CHAT_FRAME:AddMessage("Event Triggered with message: " .. msg)  -- Debug message
	DEFAULT_CHAT_FRAME:AddMessage("Message byte by byte:")--TEST
	for i = 1, #msg do--TEST
		DEFAULT_CHAT_FRAME:AddMessage(string.byte(msg, i))--TEST
	end--TEST
	local directPlayerName = string.match(msg, "(.-) a atteint") --TEST
	DEFAULT_CHAT_FRAME:AddMessage("Direct Extracted Player Name: " .. (directPlayerName or "None detected"))--TEST
	local localeMessage = HardcoreCongratsLocalization[GetLocale()].alert:gsub(" ", " ")  -- both are non-breaking spaces

    DEFAULT_CHAT_FRAME:AddMessage("Locale Message: " .. (localeMessage or "None detected"))  -- Debug message
    
    local playerName = string.match(msg, HardcoreCongratsLocalization[GetLocale()].alert)
    DEFAULT_CHAT_FRAME:AddMessage("Extracted Player Name: " .. (playerName or "None detected"))  -- Debug message

    if playerName then
        lastPlayer = playerName
        button:Show()
    end
end

--[[
Test Button

This code adds a simple test button to simulate level up events 
for testing the congrats messaging.

This allows the onEvent() handler to be fully set up before
we start triggering test events.
]]
local testButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
testButton:SetSize(100, 30)
testButton:SetPoint("TOPLEFT", 100, -100)
testButton:SetText("TEST!") 

local function getRandomPlayer()
-- Returns a random player name								  
    local names = {
    "Aeloria", "Bromli", "Thandrel", "Elowynn", "Kordric", 
    "Maelis", "Talindra", "Gromlor", "Laelith", "Nordran", 
    "Vaelora", "Thordric", "Elandra", "Rhalgar", "Lorinell"
}

    return names[math.random(#names)]
end

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
local function uncheckAllExcept(exceptIndex)
    for i = 1, #congratsMessages + 1 do
        if i ~= exceptIndex then
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false)
            end
        end
    end
end

local lastCheckbox
for i, message in ipairs(congratsMessages) do
    local checkbox = CreateFrame("CheckButton", "HardcoreCongratsCheckbox" .. i, panel, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", messageTitle, "BOTTOMLEFT", 0, -19 * i)
    checkbox.tooltip = message
    getglobal(checkbox:GetName() .. 'Text'):SetText(message)

    -- Check the checkbox for "GG!" by default
    if i == 1 then
        checkbox:SetChecked(true)
    end

    checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            -- Uncheck the checkbox for "GG!" if any other checkbox gets selected
            if i ~= 1 then
                _G["HardcoreCongratsCheckbox1"]:SetChecked(false)
            end
            selectedMessage = message
            uncheckAllExcept(i)
            randomCheckbox:SetChecked(false)
        else
            selectedMessage = congratsMessages[1]
        end
    end)
    lastCheckbox = checkbox
end


randomCheckbox:SetScript("OnClick", function(self)
    if self:GetChecked() then
        uncheckAllExcept(#congratsMessages + 1)
    else
        selectedMessage = congratsMessages[1]
        for i = 1, #congratsMessages do
            local checkbox = _G["HardcoreCongratsCheckbox" .. i]
            if checkbox then
                checkbox:SetChecked(false)
            end
        end
    end
end)

-- Printing the entire localization table
for k, v in pairs(HardcoreCongratsLocalization) do --TEST
    DEFAULT_CHAT_FRAME:AddMessage("Locale: " .. k)
    for k2, v2 in pairs(v) do
        DEFAULT_CHAT_FRAME:AddMessage("Key: " .. k2 .. ", Value: " .. v2)
    end
end

panel:SetScript("OnShow", function()
    detectedLocaleValue:SetText(GetLocale())
    lastPlayerValue:SetText(lastPlayer or "None")
end)