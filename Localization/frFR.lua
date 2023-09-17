if GetLocale() ~= "frFR" then return end

HardcoreCongratsLocalization = HardcoreCongratsLocalization or {}

HardcoreCongratsLocalization["frFR"] = {
    alert = "(.-) a atteint le niveau 60 !",
    ["Congratulate"] = "Féliciter!",
    ["Detected Locale"] = "Langue détecté:",
    ["Last player to reach 60"] = "Dernier joueur à être passé 60:",
    ["Choose a congratulation message"] = "Choisissez un message de félicitations:",
    ["Pick one at random"] = "Choisissez-en un au hasard:",
    ["Random"] = "Aléatoire",
    ["Remember"] = "Se souvenir d'un joueur pendant",
    ["Event server message"] = "Message serveur",
    ["Awaiting for someone to reach level 60..."] = "En attente d'un niveau 60...",
    ["Localization Note"] = "Copiez/collez ceci pour créer votre propre fichier de localization car Blizzard utilise des caractères spéciaux tels que les non-breaking spaces. Remplacez le nom du personnage par (.-)",
    ["Randomly pick a message"] = "Choisir un message au hasard",
    ["Customize text"] = "Définir un message à envoyer",
    ["Custom message"] = "Entrez ici votre message personnalisé",
    ["Open whisper"] = "Ouvrir la fenêtre de chuchotement (n'envoie rien)",
    ["Shift+click instruction"] = "Shift+clic pour déplacer\nAlt ou Ctrl+clic pour retirer le joueur",
    ["Players awaiting"] = "Joueurs en attente de félicitations:",
    ["hccongrats list instruction"] = "/hccongrats list - Affiche la liste des joueurs en attente de félicitations.",
    ["hccongrats reset instruction"] = "/hccongrats reset - Réinitialise l'addon aux options par défaut.",
    ["Hold shift instruction"] = "Maintenez shift pour déplacer le bouton.",
    ["Alt or Ctrl + click instruction"] = "Alt ou Ctrl + clic sur le bouton pour retirer le joueur sans le féliciter.",
    ["Reset information"] = "Les options d'HardcoreCongrats ont été réinitialisées.",
    ["hccongrats debug button"] = "/hccongrats debug - Affiche le bouton de debug.",
}
