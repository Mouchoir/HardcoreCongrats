# Hardcore Congrats for World of Warcraft

The road to level 60 is a long and perilous one in World of Warcraft Hardcore.

Those who manage to reach the maximum level deserve a little recognition!

HardcoreCongrats is a WoW add-on that lets you congratulate the valiant warriors who have achieved this achievement.

*Keep in mind that lost of player reach level 60 while appearing off-line, so the game won't let you whisper them!*

Here's a little preview of what it looks like :


![enter image description here](https://media.discordapp.net/attachments/157405815429529601/1151595800888086649/image.png)

## Features

- Automatically retrieves the names of people reaching level 60
- Opens a button to send a private message to congratulate the player
- Choose from one of the pre-recorded messages, or leave it to chance to select one
- **Shift + click** to move the congratulation button where you want it to be
- **Alt + click** or **Ctrl + click** on the button to remove the player from the congratulate list
- Automatically remove the player from the congratulate list after a certain amount of time
- Multi-language support
- Automatically fetches the server alert message for easy localization
- /hccongrats to display the add-on information

## Download
![GitHub all releases](https://img.shields.io/github/downloads/Mouchoir/HardcoreCongrats/total?label=GitHub&link=https%3A%2F%2Fgithub.com%2FMouchoir%2FHardcoreCongrats%2Freleases)
![CurseForge Downloads](https://img.shields.io/curseforge/dt/912849?label=CurseForge&link=https%3A%2F%2Flegacy.curseforge.com%2Fwow%2Faddons%2Fhardcore-congrats)



Download the .zip from the [latest release](https://github.com/Mouchoir/HardcoreCongrats/releases) or get the add-on from [CurseForge](https://legacy.curseforge.com/wow/addons/hardcore-congrats).



## Installation

Manually install the add-on by moving the files to the WoW directory. For example :
`C:\Program Files\Battle.net\World of Warcraft\_classic_era_\Interface\AddOns\HardcoreCongrats`.
This can vary depending on your WoW installation.


## Add your language

You can add support for your language by adding a new language file in /Localization/

To ease the process, the server message is automatically fetched and displayed in the add-on options panel. This will prevent you from having troubles because of the special characters Blizzard throw in there!
Just replace the name of the character with REGEX (`(.-)` is used for EN and FR language) and translate the few lines.

Once this is done, save the file in `/Localization/YOURLANGUAGECODE.lua`
Do not forget to add a line in `HardcoreCongrats.toc`!
You can also make a PR or send me the file so I can add your language to the next release.

## Change the messages sent to the players

If you feel like it, you can easily change the list of message sent to players.
Just edit `local  congratsMessages = {}` in the `HardcoreCongrats.lua` file.
## Roadmap

- Ability to congratulate an older character if it hasn't been done
- Ability to skip a congratulation
- Remove the test parts of the code
- Add more languages

## Special thanks

 - [Tigralt](https://github.com/tigralt/) for your help, patience and amazing beard!

## License

[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)

