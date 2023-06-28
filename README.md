# Playdate Analog Modular

A pluggable modular-style music making system with cables.

## Modules

Overview and status of each module. The tasks are:

* Replace Socket Sprites - use of the SocketSprite class adds more overhead and draw operations to the screen, instead the socket circles can be drawn directly onto the module background image. The socket co-ordinates are held in a Vector, eg. `self.socketInVector = Vector(x, y)`
* Optimisation - general tidy up of first pass code, minimising draw operations.
* Socket full handling - prevent a bug where you can add additional cables to an already full module
* Prevent attaching cable to self - you can add an out cable to an in socket on most modules, the mechanism is in place to prevent it (check `modId` at one cable end is not the same), just needs implementing in every mod.
* State management - to/from methods to save and load modules from saved patches.
* Remove volume encoder - some synths/drum machines may have a volume encoder, this needs removing so volume is only set in the output mixers.

All audio modules (synths, drum machines, effects, mixers/output) need some extra dev for audio routing. Chaining effects, adding modules out of the logical order (effect to output before synth to effect for example), removing effects mod, etc etc.

<hr>

### 1. Bifurcate 2

Splits a clock signal into two. 

```
         |  |  |  |  | ->
|  |  |  |
         |  |  |  |  | ->
```

#### Status - Done

* Replace Socket Sprites - Complete -3 Sprites! ✓
* Optimisation - Complete ✓
* Socket full handling -  Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 2. Bifurcate 4

Splits a clock signal into four. Useful as the first module after adding a clock.

```
         |  |  |  |  | ->
         |
         |  |  |  |  | -> 
|  |  |  |
         |  |  |  |  | ->
         |
         |  |  |  |  | ->
```

#### Status - Done

* Replace Socket Sprites - Complete -5 Sprites! ✓
* Optimisation - Complete ✓
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 3. Blackhole

Pulls clock signals into the unknown. The higher the gravity the fewer clock events make it through. Good for adding some variation and randomness.

```
|   |   |   |   |   | -> Normal clock sequence
|           |   |   | -> Blackhole event sequence
``` 

#### Status - Done

* Replace Socket Sprites - Complete -2 Sprites! ✓
* Optimisation - Complete ✓
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 4. Clock

The first module to add to any patch, it's the source of timing events that pass through cables to all other modules.

```
|  |  |  |  |  |  |  | ->
```

#### Status - Done

* Replace Socket Sprites - Complete, -1 Sprite! ✓
* Optimisation - Complete ✓
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete  (no inputs) ✓
* State management - Complete ✓

<hr>

### 5. Clock Delay

Randomly holds onto a clock event before releasing it after a delay, the delay amount is a timed interval so everything is kept in time. If an event is delayed the next clock event is ignored.

```
|   |   |   |   |   | -> Normal clock sequence
|   |     |     |   | -> Delayed sequence
``` 

#### Status - Done

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - Complete ✓
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 6. Clock Divider

Swallows every other clock event, halving the BPM.

```
|   |   |   |   |   | -> Normal Clock Sequence
|       |       |     -> Divided Sequence
```

#### Status - Done

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - Complete ✓
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 7. Clock Doubler

Add an extra event inbetween clock events. This _might_ cause some overhead if used too often, it creates a delay timer on every clock event, if you have performance issues and use this module it might be the culprit.

```
|   |   |   |   |   | -> Normal Clock Sequence
| | | | | | | | | | | -> Doubled Sequence
```

#### Status - Done

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - Complete ✓
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 8. Drum Machine

An early drum machine, the matrix of 16 encoders select a sample to play on that step. Good combined with Blackhole and Clock Delay to create random drum patterns, for more precise arrangements use the OR-606 drum machine.

#### Status - In Progress

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - todo: all the audio logic is in the mod, not the component. Needs moving at some point, plus still needs same audio routing update as all synths
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 9. Effects: One Pole Filter

Lots of work to do here, distorts the audio, some bad param somewhere. Not available.

#### Status - In Progress

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - TODO - audio is corrupted. 
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 10. Effects: Ring Modulator

Basic implementation done - lots to do.

#### Status - In Progress

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - TODO - check status, might be OK
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management  - Complete ✓

### 11. Label

Add a note to your patch. 

#### Status - Done

* Replace Socket Sprites - Complete (none) ✓
* Optimisation - Complete ✓
* Socket full handling - Complete (none) ✓
* Prevent attaching cable to self - Complete (none) ✓
* State management - Complete ✓

<hr>

### 12. Micro Synth

A very small synth module. You can only change the waveform type by opening the module menu. 

#### Status - In Progress

* Replace Socket Sprites - Complete, -2 Sprites! ✓
* Optimisation - todo: still needs same audio routing update as all synths
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓
* Remove volume encoder - Complete ✓

<hr>
 
### 13. Mixers: 4 Outputs

#### Status - In Progress 

* Replace Socket Sprites - Complete, -4 Sprites! ✓
* Optimisation - todo: still needs same audio routing update as all synths
* Socket full handling - Complete ✓
* Prevent attaching cable to self - Complete ✓
* State management - Complete ✓

<hr>

### 14. Mixers: 8 Outputs

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 15. Normalised-to-Midi

Presented as Value2Midi, needs a rethink on name. Takes an input in range 0.0 to 1.0 and outputs a valie midi note value. Currently hard-coded to C Major. Eventually should have different keys available. 

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 16. OR-606

A clone fo the Roland TR-606 drum machine. Supports variable pattern lengths per drum type. Best used with a clean clock signal (not clock delay or Blackhole).

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 17. OR-808

A clone of the Roland TR-808. Not available yet, will be a copy of the OR-606 with different samples and a tweaked UI.

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 18. Print

Displays input values to screen, then emits the event at the ouput. Meant for debug/dev purposes.

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 19. Sequencer Grid

A 16 step sequencer, an early module, needs a lot of work. Doesn't support keys yet, just raw midi note values 0-127.

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 20. Switch

A SPST switch, used to disable parts of a patch.

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 21. SPDT Switch

A SPDT switch, used to swap between two different routes in a patch. 

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 22. Synth

The primary synth with full controls and automation (for the ADSR Envelope and the two Teenage Engineering swaveform types).

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>

### 23. Speaker Module

Actually a 1X Mixer, needs moving to the Mixers directory.

#### Status - In Progress

* Replace Socket Sprites - TODO
* Optimisation - TODO
* Socket full handling - TODO
* Prevent attaching cable to self - TODO
* State management - TODO

<hr>





# Old Notes

## Code

`Source/Modules/SomeModule` holds everything needed for a module (the `Components` package should eventually disappear). Also replace Module with Mod. I'm bored of typing Module. Modules can still have Components, it doesn't matter, as far as the overall system is concerned the interface is the Module.

Always use `setInCable(cable)` and `setOutCable(cable)` even if there's only a single in or out.

## Ghosts

A 'ghost cable' is a semi-transparent cable used to connect modules, when B is pressed over a module, if the module can accept the cable, the ghost cable is cloned and a real cable is connected. A ghost cable does not propagate events, a reified cable does.

The ghost cable logic should prevent connecting modules to themselves, and prevent attaching cable to already connected sockets - this is a work in progress...

A 'ghost module' is a wireframe outline used to place new modules on the canvas.

## Z Values

Screens push and pop, cables draw on top of the filename dialog, for this reason we need some Z value ranges to ensure things draw correctly. See [Playdate Sprite docs](https://sdk.play.date/2.0.0/Inside%20Playdate.html#m-graphics.sprite.setZIndex): `Valid values for z are in the range (-32768, 32767)`:

* The Top
* Save Dialog - 31000+
* Main Patch Screen reticle sprite - 30000
* Main Patch Screen module menus - 29000
* Main Patch Screen cables - 28000
* Main Patch screen with cables, reticle etc - 28000+
* The Bottom

## Modules

A module is something the user can add to screen, a clock, a sequencer, drum machine, etc. A Module class must have the following:

* `local modtype = "SomeMod"`
* `Module:modId()` - `self.modId` format, on init: `modType .. "-" .. playdate.getSecondsSinceEpoch()`, the modId is kept in any cable attached to a module, if the module is deleted the cable can be removed as well.
* `Module.ghostModule()` - a single Sprite used to place the Module on the canvas
* `Module:type()` - returns the Module class name as a String
* `Module:tryConnectGhostOut(x, y, ghostCable)` - connect the 'in' end of the ghost cable to an out socket. Simple modules don't need to use x and y coordinates, they can just use the next available, or only, out socket. Modules could return `false` here if they have multiple outs serving different uses (and therefore need to take distance to socket into account), and if their output are all occupied.
* `Module:tryConnectGhostIn(x, y, ghostCable)` - verify a cable can be connected to an in socket. All modules except the Clock Module have an in. This method could return false if the distance to a socket is too far (for modules where there are different input type) or if there are no input sockets available. Most modules should auto-connect a cable to the next available input - more often modules will just have one input.
* `Module:setOutCable(cable)` and/or  `Module:setInCable(cable)` - once the ghost cable has validated the connection a concrete 'reified' cable is passed to the module to start passing events.
* `Module:collision(x, y)`
* `Module:displayContextMenu(listener)` - delete a module, delete cables, show info, etc
* `Module:evaporate()` - used to remove module from the screen, should handle all child sprites

## Input Handling

When the ModularScreen is in standard mode the A button handles modules and the B button handles cables. An A press in empty space brings up the 'add module' popup menu, pressing A on a module will bring up the modules context menu. Pressing B on a module will connect the ghost cable to an out socket ready to be connected to an in socket of another module.

## Module Delete

This is convoluted, and there will be better patterns for it but this keeps the pain within the modules themselves, the system-wide state remains very low (everything is concrete, the cables know the modId of what they're connected to)

* User launches context menu for a module (`ModularScreen:showModuleContextMenu(x, y)`) and chooses `Remove`
* If the module can `evaporate` it does: `if module.evaporate ~= nil then ...`.
* The evaporate method should have a callback, eg: `function ClockModule:evaporate(onDetachConnected)`, a module checks to see if sockets have cable connected, it disconnects the cables in itself: `someSocket:setCable(nil)`, maybe it has an `unplug` method. Before telling the `PatchCable` to remove itself first call the callback to the module at the other end can disconnect too. Full example, after this the parent can remove the object entirely ready for garbage collection:

```lua
function ClockModule:evaporate(onDetachConnected)
	--first detach cables
	if self.clockComponent:connected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.clockComponent:unplug()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	self.clockEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.labelSprite, self.bangSprite, self.socketSprite})
	self.bangSprite = nil--socket callback may still cause it to display, so remove it entirely
	self:remove()
end
```

## Patch Load/Save

Work in progress... I want users to have a list of saved patches. To do that there needs to be a mechanism to save and load the entire state of the 'canvas'. Each module needs a `toJson()` and `fromJson()`, then I need to think about cable io. Modules should have a modId constructor argument so they can be resurrected:

```lua
function AMod:init(xx, yy, modId)
AMod.super.init(self)

if modId == nil then
	self.modId = modType .. playdate.getSecondsSinceEpoch()
else
	self.modId = modId
end
```

State to Json, each module should have a `toState()` method that return a table with everything required to recreate it, the the moduleManager will serialise to JSON and save to file:

```lua
function ClockMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.bpmEncoderValue = self.clockEncoder:getValue()
	return modState
end
```

Coming the other way each module should have a `fromState(modState)` _if_ they hold any state, this should normally be the encoder raw normalised value:

```lua
function ClockMod:fromState(modState)
	self.clockEncoder:setValue(modState.bpmEncoderValue)
end
```


| Annoy | Arp |
| --- | --- |
| ![](./readme_assets/annoying.jpg) | ![](./readme_assets/theory.png) |
 
