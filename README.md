# Potential Character Progression
### Ver. 1.0.2
Potential Character Progression (PCP) is an OpenMW Lua mod that changes Morrowind's level-up mechanics. The first aim of PCP is to eliminate any need to level up optimally, freeing you from having to raise your character's skills in any specific way. The second aim is to avoid sacrificing player input in the level-up process or changing any other mechanics.

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
### Attribute Capping Method
Attributes have a configurable maximum value that they cannot be raised above. If set to 0, the corresponding attribute can be raised infinitely

This setting decides whether attributes will share one maximum value, use differing maximums if they are favored, or use completely unique maximums. (Default: Shared)
### Shared/Favored/Unfavored/Unique Attribute Caps
(Default: All 100)
</Details>
<Details>
<Summary>Health Settings</Summary>

These settings affect how the player's maximum health is calculated. By default, maximum health works the same as in vanilla Morrowind.

### Retroactive Health Gain
If enabled, health gained from level-ups will be calculated as if relevant attributes had always been at their current value. (Default: OFF)
### Retroactive Starting Health
If this and 'Retroactive Health Gain' are enabled, raising attributes will affect the initial health from character creation. (Default: OFF)
### Realistic Retroactive Health Gain
If this and 'Retroactive Health Gain' are enabled, health gained from level-ups will be calculated as if relevant attributes had been raised to their current value as early as possible. (Default: OFF)
### Realistic Retroactive Health Increment
Calculations for 'Realistic Retroactive Health Gain' will assume that attributes were raised by this value each level. (Default: 5)
### Custom Health Calculation
If enabled, health will be calculated using a weighted average of attribute values instead of just endurance and strength. (Default: OFF)
### Custom Health Coefficients
If 'Custom Health Calculation' is enabled, health gain and starting health will be derived from this average: `(sum of (coeffs * attributes)) / (sum of coeffs)` (Default: Configured to match NCGDMW Lua)
### Custom Health Gain Multiplier
If 'Custom Health Calculation' is enabled, health gained from level-ups will be equal to the weighted average above multiplied by this value. (Default: 0.1)
</Details>
<Details>
<Summary>Balance Settings</Summary>

These settings will alter the balance of character progression. Be careful when changing them.

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
### Level Progress Per Misc. Skill Increase
(Default: 1)
### Level Progress Per Minor Skill Increase
(Default: 1)
### Level Progress Per Major Skill Increase
(Default: 1)
</Details>
<Details>
<Summary>Skill Settings</Summary>

### Custom Skill-Attribute Assignment
If enabled, skills can be configured to contribute towards different attributes' potential. Total potential gained from a skill increase will remain the same, but it will be divided between attributes by the adjustable ratios below. (DEFAULT: OFF)

#### Acrobatics
STR 3 / INT 0 / WIL 0 / AGI 1 / SPD 2 / END 1 / PER 0 / LUC 1
#### Alchemy
STR 0 / INT 5 / WIL 0 / AGI 0 / SPD 0 / END 1 / PER 1 / LUC 1
#### Alteration
STR 0 / INT 2 / WIL 5 / AGI 0 / SPD 0 / END 0 / PER 0 / LUC 1
#### Armorer
STR 4 / INT 0 / WIL 0 / AGI 0 / SPD 0 / END 3 / PER 0 / LUC 1
#### Athletics
STR 0 / INT 0 / WIL 1 / AGI 0 / SPD 4 / END 2 / PER 0 / LUC 1
#### Axe
STR 4 / INT 0 / WIL 0 / AGI 1 / SPD 0 / END 2 / PER 0 / LUC 1
#### Block
STR 0 / INT 0 / WIL 0 / AGI 3 / SPD 2 / END 2 / PER 0 / LUC 1
#### Blunt Weapon
STR 3 / INT 0 / WIL 2 / AGI 1 / SPD 1 / END 0 / PER 0 / LUC 1
#### Conjuration
STR 0 / INT 4 / WIL 2 / AGI 0 / SPD 0 / END 0 / PER 2 / LUC 1
#### Destruction
STR 0 / INT 1 / WIL 6 / AGI 0 / SPD 0 / END 0 / PER 0 / LUC 1
#### Enchant
STR 0 / INT 6 / WIL 0 / AGI 0 / SPD 0 / END 0 / PER 1 / LUC 1
#### Hand-to-hand
STR 1 / INT 0 / WIL 0 / AGI 1 / SPD 4 / END 1 / PER 0 / LUC 1
#### Heavy Armor
STR 3 / INT 0 / WIL 0 / AGI 0 / SPD 0 / END 4 / PER 0 / LUC 1
#### Illusion
STR 0 / INT 1 / WIL 1 / AGI 0 / SPD 0 / END 0 / PER 5 / LUC 1
#### Light Armor
STR 0 / INT 0 / WIL 1 / AGI 3 / SPD 3 / END 0 / PER 0 / LUC 1
#### Long Blade
STR 3 / INT 0 / WIL 0 / AGI 2 / SPD 1 / END 1 / PER 0 / LUC 1
#### Marksman
STR 2 / INT 1 / WIL 0 / AGI 4 / SPD 0 / END 0 / PER 0 / LUC 1
#### Medium Armor
STR 2 / INT 0 / WIL 0 / AGI 1 / SPD 0 / END 4 / PER 0 / LUC 1
#### Mercantile
STR 0 / INT 1 / WIL 0 / AGI 0 / SPD 0 / END 0 / PER 6 / LUC 1
#### Mysticism
STR 0 / INT 2 / WIL 4 / AGI 0 / SPD 0 / END 0 / PER 1 / LUC 1
#### Restoration
STR 0 / INT 1 / WIL 4 / AGI 0 / SPD 0 / END 0 / PER 2 / LUC 1
#### Security
STR 0 / INT 3 / WIL 0 / AGI 3 / SPD 0 / END 0 / PER 1 / LUC 1
#### Short Blade
STR 1 / INT 0 / WIL 0 / AGI 2 / SPD 4 / END 0 / PER 0 / LUC 1
#### Sneak
STR 0 / INT 0 / WIL 0 / AGI 4 / SPD 2 / END 0 / PER 1 / LUC 1
#### Spear
STR 1 / INT 0 / WIL 0 / AGI 1 / SPD 1 / END 4 / PER 0 / LUC 1
#### Speechcraft
STR 0 / INT 0 / WIL 0 / AGI 0 / SPD 0 / END 0 / PER 7 / LUC 1
#### Unarmored
STR 0 / INT 0 / WIL 2 / AGI 0 / SPD 3 / END 2 / PER 0 / LUC 1
</Details>
<Details>
<Summary>Data Settings</Summary>

### Clear Data
Clicking this button will reset the data used to track character progression, making it as if this mod had just been added to the save file. This should only be used in niche cases, like redoing character creation in an existing save.

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
PCP requires OpenMW version 0.49 or later. If your version is too old, a warning will appear in the log. (Press F10 or check openmw.log)
### Compatibility
Anything that changes the level-up process likely won't work with PCP, but mods that occasionally increase/decrease attributes outside of level-ups are fine. Mods changing character creation or skill progression should work too. Specifically, Custom Skill Caps (https://github.com/Qlonever/CSC-OpenMW) is compatible with PCP.
PCP can be added to an existing save without issues, but retroactive health calculations won't account for level-ups performed prior to installing it.
### Known Issues
Currently, the potential menu can't be bound to controller buttons; this is because the setting uses a custom format. This will be fixed when the built-in binding functions support default bindings and allow bindings to be read.

MWscripts or console commands using modattribute functions can't increase attributes past 100, even with this mod installed.

If you encounter any bugs, please create an issue or inform me some other way.
### Updating
Updating this mod on an existing save shouldn't pose any major problems. A message will appear in-game if there are any issues.

## Credits
Author: Qlonever

Special thanks to everyone in the OpenMW Discord server who answered my Lua modding questions, especially S3ctor.

Additional thanks to the creators of NCGDMW Lua for letting me use some of their settings as defaults in PCP. (https://www.nexusmods.com/morrowind/mods/53136)

## Other Sources
This mod can be found on Nexus Mods: https://www.nexusmods.com/morrowind/mods/55264

Numbered releases will be uploaded there.
