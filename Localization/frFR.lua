if GetLocale() ~= "frFR" then return end

HardcoreCongratsLocalization = HardcoreCongratsLocalization or {}

HardcoreCongratsLocalization["frFR"] = {
    alert = "(.-) a atteint le niveau 60 !", --Last two spaces are non-breaking spaces !
    ["Detected Locale"] = "Langue détecté:",
    ["Last player to reach 60"] = "Dernier joueur à être passé 60:",
    ["Choose a congratulation message"] = "Choisissez un message de félicitations:",
    ["Pick one at random"] = "Choisissez-en un au hasard:",
	["Event server message"] = "Message serveur",
	["Awaiting for someone to reach level 60..."] = "En attente d'un niveau 60..."
}
