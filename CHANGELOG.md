### Changelog
## 1.0.0
- Initial version

## 1.0.1
- Added a new setting: "Retroactive Starting Health"
- Added four optional .omwaddons for different level-up requirement settings
- Added a level progress indicator to the potential menu
- Fixed a bug when adding PCP to a save with >= 20 level-up progress
- Fixed OpenMW version warning not working
- Fixed health calculations not using the `fLevelUpHealthEndMult` GMST

## 1.0.2
- Added a new setting: "Custom Health Calculation"
- Added a new setting: "Cap Attributes Individually"
- Added more optional .omwaddons for level-up requirements
- Fixed class skills/attributes not initializing correctly for the first play session
- Fixed issues with health gain logic
- Fixed potential displaying incorrectly in rare cases
- Fixed high resolution textures displaying poorly in the menu
- Fixed dependencies on some optional .omwaddons
- Bumped settings version

## 1.1.0
- Added a new setting: "Custom Skill-Attribute Assignment"
- Added a new setting: "Realistic Retroactive Health Gain"
- Added new settings: "Favored/Unfavored Attribute Cap"
- Added new settings: "Level Progress Per Misc./Minor/Major Skill Increase"
- Added support for level-up messages past 21
- Added a function to clear progression data from a save file
- Added code to grant potential for prior skill increases when adding PCP to a save
- Added code to automatically migrate certain settings values
- Added more specific notifications for settings being removed by updates
- Tweaked descriptions for some settings
- Tweaked dimensions of elements in the potential menu
- Exposed some hardcoded UI dimensions to localizations
- Fixed several issues with settings UI
- Fixed a bug when using or increasing an already maxed skill
- Fixed an issue with attribute multiplier values when removing PCP from a save
- Fixed an issue with settings version detection
- Fixed an issue with dependent settings not properly initializing

## 1.1.1
- Fixed a bug preventing skills from increasing when Custom Skill Caps is installed
- Fixed "Clear Data" button text not being in localization files