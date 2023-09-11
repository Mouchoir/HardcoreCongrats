
# Hardcore Congrats for World of Warcraft

The road to level 60 is a long and perilous one in World of Warcraft Hardcore.

Those who manage to reach the maximum level deserve a little recognition!

HardcoreCongrats is a WoW add-on that lets you congratulate the valiant warriors who have achieved this achievement.

⚠ This add-on is currently in development anc contains test code. ⚠


## Features

- Automatically retrieves the names of people reaching level 60
- Opens a button to send a private message to congratulate the player
- Choose from one of four pre-recorded messages, or leave it to chance to select one
- Multi-language support

## Installation

Manually install the add-on by moving the files to the WoW directory. For example :
`C:\Program Files\Battle.net\World of Warcraft\_classic_era_\Interface\AddOns\HardcoreCongrats`.
This can vary depending on your WoW installation.


## Add your language

You can add support for your language by adding a new language file in /Localization/

```lua
if GetLocale() ~= "YOURLANGUAGECODE" then return end -- Your language code, for example "enUS"

HardcoreCongratsLocalization = HardcoreCongratsLocalization or {}

HardcoreCongratsLocalization["YOURLANGUAGECODE"] = { -- Your language code
    alert = "^(.+) has reached level 60!", -- Messaged displayed by the server when someone reaches 60. The ^(.+) part is meant to find the player's name.
    ["Detected Locale"] = "Detected Locale:", -- Displayed in the add-on's options
    ["Last player to reach 60"] = "Last player to reach 60:" -- Displayed in the add-on's options
}
```

Once this is done, save the file in `/Localization/YOURLANGUAGECODE.lua`
Do not forget to add a line in `HardcoreCongrats.toc` and 

## Roadmap

- Ability to congratulate an older character if it hasn't been done
- Ability to skip a congratulation
- Remove the test parts of the code
- Add more languages


## License

[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)

