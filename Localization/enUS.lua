if GetLocale() ~= "enUS" then return end

HardcoreCongratsLocalization = HardcoreCongratsLocalization or {}

HardcoreCongratsLocalization["enUS"] = {
    alert = "(.-) has reached level 60!",
    ["Congratulate"] = "Congratulate!",
    ["Detected Locale"] = "Detected Locale:",
    ["Last player to reach 60"] = "Last player to reach 60:",
    ["Choose a congratulation message"] = "Choose a congratulation message:",
    ["Pick one at random"] = "Pick one at random:",
    ["Random"] = "Random",
    ["Remember"] = "Remember a player for",
    ["Event server message"] = "Event server message",
    ["Awaiting for someone to reach level 60..."] = "Awaiting for someone to reach level 60...",
    ["Localization Note"] = "Copy/paste this to create the localization file in your own language since Blizzard sometimes uses special characters such as non-breakable spaces. Then replace the character's name with (.-).",
    ["Randomly pick a message"] = "Randomly pick a message",
    ["Shift+click instruction"] = "Shift+click to move\nAlt or Ctrl+click to remove player",
    ["No players awaiting"] = "No players are awaiting congratulations.",
    ["Players awaiting"] = "Players awaiting congratulations:",
    ["hccongrats list instruction"] = "/hccongrats list - Displays list of players awaiting congratulations.",
    ["hccongrats reset instruction"] = "/hccongrats reset - Resets the addon to default options.",
    ["Hold shift instruction"] = "Hold shift to move the button.",
    ["Alt or Ctrl + click instruction"] = "Alt or Ctrl + click on the button to remove the player without congratulating.",
    ["Reset information"] = "HardcoreCongrats settings have been reset to default.",
    ["hccongrats debug button"] = "/hccongrats debug - Displays the debug button.",
}
