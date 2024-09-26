# Potential Character Progression
Potential Character Progression (PCP) is an OpenMW lua mod that changes Morrowind's level-up mechanics. The first aim of PCP is to eliminate any need to level up optimally, freeing you from having to raise your character's skills in any specific way. The second aim is to do this without removing player choice from any part of character progression.

## Potential
In this mod, attribute progression is still linked to skills. However, instead of multipliers that might go to waste, attributes gain 0.5 points of potential every time an associated skill is raised. An attribute's potential represents how much it can be increased by spending experience.

## Experience
Once you've raised any skill or skills 20 times, you will level up the next time you rest. You are awarded 15 experience points upon leveling up, which you can distribute among your attributes however you'd like. One point of experience will increase an attribute by one point, as long as it has potential to grow. Attributes can be raised above their potential, but more experience is required; for favored attributes, this additional cost is reduced. By default, you will gain more experience than potential to spend it with.

## No Wasting
Potential and experience won't go away until they're used. Once you level up, you're free to save them for as long as you want. Press the L key at any time to check/use your potential and experience.

## Character Creation
Character creation is left untouched. However, given that all skills contribute to leveling up and favored attributes can be raised more easily, you may benefit from making your custom classes differently. Major/minor skills no longer represent what your character must do in order to level up, but rather what they're already good at and can progress in more easily. Feel free to pick all or none of the skills for one attribute, since it won't make your level-ups more difficult or less rewarding. If you want to prioritize an attribute but don't plan on using its skills very much, choosing it as a favored attribute will allow you to raise it much faster.

## Balance
By default, PCP is balanced so that 20 skill increases will allow you to raise your attributes by about 11 points total, not accounting for the benefits of favored attributes. This is equivalent to a somewhat efficient level-up in Morrowind's regular mechanics, which would allow you to raise two attributes by five points and another by one point. (like Luck, which can't get multipliers normally) Leveling up may take longer due to the increased requirement of 20, but miscellaneous skills can contribute to this as well, so it may not be a big difference depending on your playstyle. With PCP, you're no longer under any pressure to watch what skills you increase, so feel free to buy whatever miscellaneous training services you come across. However, this mod is also highly configurable, so you can make your attributes increase more slowly or quickly if you want. (Check the Balance Settings section below)

## Settings
<Details>
<Summary>Basic Settings</Summary>

### Potential Menu Key
This key opens up the potential menu, where you can check and use your potential and experience. This is the same menu that you see upon leveling up. (Default: L)
### Retroactive Health Gain
If enabled, raising endurance will affect the health gained from previous level-ups as well. (Default: OFF)
### Allow Jail Time Exploit
If enabled, skill points lost in jail and then regained later will still contribute to potential and level-up progress. (Default: OFF)
### Attributes Maximum Value
You cannot raise attributes past this value. (Default: 100)
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

### Compatibility
Any mod that affects the level-up/attribute increasing process probably won't work with PCP, but plugins that increase/decrease attributes via dialogue or the occasional scripted object aren't a problem. Mods affecting skill progression should work just fine too.
### Requirements
PCP requires a development build of OpenMW newer than August 2024, or any release newer than 0.48.
### Installation
Add the `00 Core` directory of this mod to OpenMW as a data path, then make sure `PotentialCharacterProgression.omwaddon` and `PotentialCharacterProgression.omwscripts` are enabled as content files.

Example:

```
data="C:/games/OpenMWMods/Leveling/Potential Character Progression/00 Core"
content=PotentialCharacterProgression.omwaddon
content=PotentialCharacterProgression.omwscripts
```
### Credits
Author: Qlonever

Special thanks to everyone in the OpenMW Discord server who answered my Lua modding questions, especially S3ctor.