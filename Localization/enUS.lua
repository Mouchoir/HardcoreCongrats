if GetLocale() ~= "enUS" then return end

HardcoreCongratsLocalization = HardcoreCongratsLocalization or {}

HardcoreCongratsLocalization["enUS"] = {
    alert = "(.-) has reached level 60!",
    ["Detected Locale"] = "Detected Locale:",
    ["Last player to reach 60"] = "Last player to reach 60:",
    ["Choose a congratulation message"] = "Choose a congratulation message:",
    ["Pick one at random"] = "Pick one at random:",
	["Event server message"] = "Event server message",
	["Awaiting for someone to reach level 60..."] = "Awaiting for someone to reach level 60...",
	["Localization Note"] = "Copy/paste this to create the localization file in your own language since Blizzard sometimes uses special characters such as non-breakable spaces. Then replace the character's name with (.-)."
}
