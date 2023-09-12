if GetLocale() ~= "frFR" then return end

HardcoreCongratsLocalization = HardcoreCongratsLocalization or {}

HardcoreCongratsLocalization["frFR"] = {
    alert = "(.-) a atteint le niveau 60 !", --Last two spaces are non-breaking spaces !
    ["Detected Locale"] = "Langue détecté:",
    ["Last player to reach 60"] = "Dernier joueur à être passé 60:",
    ["Choose a congratulation message"] = "Choisissez un message de félicitations:",
    ["Pick one at random"] = "Choisissez-en un au hasard:",
    ["Remember"] = "Se souvenir d'un joueur pendant",
    ["Minutes"] = "min.",
	["Event server message"] = "Message serveur",
	["Awaiting for someone to reach level 60..."] = "En attente d'un niveau 60...",
	["Localization Note"] = "Copiez/collez ceci pour créer votre propre fichier de localization car Blizzard utilise des caractères spéciaux tels que les non-breaking spaces. Remplacez le nom du personnage par (.-)"
}
