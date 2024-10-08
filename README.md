# Potential Character Progression
### Ver. 1.0.2
Potential Character Progression (PCP) is an OpenMW lua mod that changes Morrowind's level-up mechanics. The first aim of PCP is to eliminate any need to level up optimally, freeing you from having to raise your character's skills in any specific way. The second aim is to avoid sacrificing player input in the level-up process or changing any other mechanics.

## Potential
In this mod, attribute progression is still linked to skills. However, instead of multipliers, attributes gain 0.5 points of potential every time an associated skill is raised. An attribute's potential represents how much it can be increased by spending experience.

## Experience
Upon leveling up, you are awarded 15 experience points which you can distribute among your attributes however you'd like. One point of experience will increase an attribute by one point as long as it has potential to grow. Attributes can be raised above their potential, but more experience is required; for favored attributes, this additional cost is reduced. By default, you will gain more experience than potential.

## Leveling Up
Leveling up works mostly the same as normal, but the requirement is now 20 skill increases. All skills contribute to this, though, not just the major or minor skills for your class.

## No Wasted Effort
Potential and experience won't go away until they're used. Once you level up, you're free to save them for as long as you want. Press the L key at any time to check/use your potential and experience.

## Character Creation
Character creation is left completely untouched. However, the changes in this mod might inform your class creation. Major/minor skills no longer represent what your character must do in order to level up, but rather what they're already good at and can progress in more easily. Feel free to pick all or none of the skills for one attribute, since it won't make your level-ups more difficult or less rewarding. If you want to prioritize an attribute but don't plan on using its skills very much, choosing it as a favored attribute will allow you to raise it much faster.

## Balance
By default, PCP is balanced so that 20 skill increases will allow you to raise your attributes by about 11 points total, not accounting for the benefits of favored attributes. This is equivalent to a somewhat efficient level-up in Morrowind's regular mechanics, which would allow you to raise two attributes by five points and another by one point. (like Luck, which can't get multipliers normally) Leveling up may take longer due to the increased requirement of 20, but since miscellaneous skills can contribute to this as well, the difference will depend on your playstyle. With PCP, you're no longer under any pressure to watch what skills you increase, so feel free to buy whatever miscellaneous training services you come across. However, this mod is also highly configurable, so you can make your attributes increase more slowly or quickly if you want. (See the "Balance Settings" section below)

## Settings
<Details>
<Summary>Basic Settings</Summary>

### Potential Menu Key
This key opens up the potential menu, where you can check and use your potential and experience. This is the same menu that you see upon leveling up. (Default: L)
### Allow Jail Time Exploit
If enabled, skill points lost in jail and then regained later will still contribute to potential and level-up progress. (Default: OFF)
### Attribute Cap
You cannot raise attributes above this value. (Default: 100)
### Cap Attributes Individually
If enabled, each attribute will have a configurable maximum value that it cannot be raised above. (Default: OFF)
</Details>
<Details>
<Summary>Health Settings</Summary>

### Retroactive Health Gain
If enabled, raising attributes will affect the health gained from previous level-ups as well. (Default: OFF)
### Retroactive Starting Health
If this and 'Retroactive Health Gain' are enabled, raising attributes will affect the initial health from character creation. (Default: OFF)
### Custom Health Calculation
If enabled, health will be calculated using a weighted average of attribute values, instead of just endurance and strength. (Default: OFF)
### Custom Health Coefficients
If 'Custom Health Calculation' is enabled, health gain and starting health will be derived from this average: `(sum of (coeffs * attributes)) / (sum of coeffs)` (Default: Configured to match NCGDMW Lua)
### Custom Health Gain Multiplier
If 'Custom Health Calculation' is enabled, health gained from level-ups will be equal to the weighted average above multiplied by this value. (Default: 0.1)
</Details>
<Details>
<Summary>Balance Settings</Summary>

### Potential Gained Per Misc. Skill Increase
(Default: 0.5)
### Potential Gained Per Minor Skill Increase
(Default: 0.5)
### Potential Gained Per Major Skill Increase
(Default: 0.5)
### Experience Gained Per Level-Up
(Default: 15)
### Experience Cost To Raise Attribute
(Default: 1)
### To Raise Attribute Over Potential
(Default: 5)
### To Raise Favored Attribute
(Default: 1)
### To Raise Favored Attribute Over Potential
(Default: 2)
</Details>

PCP includes optional modules that change how many skill increases are required to level up. The default is 20, but you can also choose between 10, 15, 25, 30, 40, or 50. See the "Installation" section below.

## Installation
Add the `00 Core` directory of this mod to OpenMW as a data path. If you'd like to change the setting for level-up requirements, add one of the `01 Modified Level-Up Requirements` directories as a data path as well.

Make sure `PotentialCharacterProgression.omwaddon` and `PotentialCharacterProgression.omwscripts` are enabled as content files. If you're using one of the optional `01` modules, make sure its .omwaddon is enabled after `PotentialCharacterProgression.omwaddon`.

Example:
```
data="C:/games/OpenMWMods/Leveling/Potential Character Progression/00 Core"
content=PotentialCharacterProgression.omwaddon
content=PotentialCharacterProgression.omwscripts
```
Example with optional module:
```
data="C:/games/OpenMWMods/Leveling/Potential Character Progression/00 Core"
data="C:/games/OpenMWMods/Leveling/Potential Character Progression/01 Modified Level-Up Requirements (15)"
content=PotentialCharacterProgression.omwaddon
content=PotentialCharacterProgression_ModifiedLevelUps_15.omwaddon
content=PotentialCharacterProgression.omwscripts
```
### Requirements
PCP requires a development build of OpenMW newer than August 2024, or any release newer than 0.48. If your version is too old, a warning will appear in the log. (Press F10 or check openmw.log)
### Compatibility
Anything that changes the level-up process likely won't work with PCP, but mods that occasionally increase/decrease attributes outside of level-ups are fine. Mods changing character creation or skill progression should work too.
Also, PCP can be added to an existing save without issues.
### Updating
Updating this mod on an existing save shouldn't pose any major problems. However, if existing mod settings change between versions, you may have to re-configure them. An in-game message will inform you if this happens.

## Credits
Author: Qlonever

Special thanks to everyone in the OpenMW Discord server who answered my Lua modding questions, especially S3ctor.
Additional thanks to the creators of NCGDMW Lua for letting me use some of their settings as defaults in PCP. (https://www.nexusmods.com/morrowind/mods/53136)

## Source
This mod can be found on Github: https://github.com/Qlonever/PCP-OpenMW 
Updates there will be smaller and more frequent.
