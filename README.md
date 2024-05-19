# Saddle Up!
A simple addon to automatically summon a random mount

## Usage

This Addon allows you to summon a random mount either by clicking a new button in the Mount UI, or by using the `/SaddleUp` console command

By default it will attempt to summon a random mount from any of your configured "favorites" -- if you havn't configured any, it will fall back to selecting any available mount.

In the Options panel, you can further configure the Addon:

- Prefer Flying Mounts when they are usable
If selected and you have a mix of flying and non-flying mounts set as your favorites, and you are in a flying area, it will only summon a flying mount. In other words, it won't summon a non-flying mount in a flying area.

- Allow Druid Flight Form as a flying mount
If selected the addon will include a random chance to select the Druid Flight Form as a mount, when in a flying area. Note that the addon cannot actually trigger the flight form and therefore you need to do that through a macro. The helpful button 'Generate Druid Macro' shown beneath this option will generate a macro to do this for you

- Show Debug Messages
Shows some debug messages that show what the addon is doing