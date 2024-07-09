# Ichigo Template
###### Created by Sudospective


## What is Ichigo Template?
Ichigo Template (イチゴ) is a gimmick template for Project OutFox powered by the in-engine PandaTemplate. You can think of it as the base PandaTemplate with some extra features included.


## What features does the template have?
Ichigo Template allows you to not only streamline your gimmick creation process, but it also provides simple-to-use tools for complex features like classes and objects. Ichigo Template can be used for normal gimmick files, minigames, etc. The only limits are the ones you set yourself! Ichigo Template is also fully encapsulated in its own local environment that is garbage collected after a screen change, so you can be sure that nothing is leaked once the template is no longer in use by the engine. No more pesky globals hanging around after a gimmick file is finished, not a single one!


## Getting Started

### Template Variables and Functions
| Name | Description |
| - | - |
| **Constants** |
| SCX | SCREEN_CENTER_X |
| SCY | SCREEN_CENTER_Y |
| SW | SCREEN_WIDTH |
| SH | SCREEN_HEIGHT |
| SL | SCREEN_LEFT |
| SR | SCREEN_RIGHT |
| ST | SCREEN_TOP |
| SB | SCREEN_BOTTOM |
| DW | Display width |
| DH | Display height |
| SONG | Current Song object |
| SONG_POS | Song Position object |
| SRC_ROOT | Source root folder ("/Songs/Pack/Song/src") |
| INC_ROOT | Include root folder ("/Songs/Pack/Song/include") |
| **Variables** |
| __version | Ichigo Template version (useful for issue reports) |
| Style | Current style from GameState |
| Actors | Table containing all actors (ex: Actors.P1) |
| Players | Shorthand enums for players (ex: "P1") |
| Options | Table containing PlayerOptions for players |
| Charts | Table containing charts for song |
| Profiles | Table containing profiles for machine and players |
| States | Table containing PlayerState for players |
| **Functions** |
| run '*file.lua*' | Run a file within /src |
| include '*file*' | Include a file within /include |
| class '*name*' {} | Create a class |
| namespace '*name*' {} | Create a namespace |
| **Standard Library** |
| isan() | Force legacy modreader |
| rei() | Disable modreader |
| ni() | Require two players |
| go() | Check for OutFox Alpha V |
| tokei() | Time-based mods |
| register(*PlayerOption*) | Register a PlayerOption to the template |
| setupPlayer(*ActorProxy*) | Setup an ActorProxy to proxy a player |
| setupJudgment(*ActorProxy*) | Setup an ActorProxy to proxy a judgment |
| setupCombo(*ActorProxy*) | Setup an ActorProxy to proxy a combo |

### Adding Gimmicks in Ichigo
Gimmicks are added inside `gimmicks.lua` in the `src` folder. They are added by calling the function `gimmick`. Here are some examples:
```lua
-- set 2 xmod on beat 0
gimmick {0, 2, 'xmod'}
-- ease 100 drunk on beat 2 for 4 beats
gimmick {2, 4, Tweens.easeInOutQuint, 0, 100, 'drunk'}
-- call a function on beat 8
gimmick {8, function() SCREENMAN:SystemMessage('hewo') end}
-- perframe on beat 12 for 2 beats
gimmick {12, 2, function(beat) print(beat) end}
-- you can also ease functions
gimmick {16, 4, Tweens.easeOutElastic, -SCREEN_CENTER_Y, SCREEN_CENTER_Y, function(p) myActor:y(p) end}
```

### Adding Actors in Ichigo
There are two ways to add actors in Ichigo. The first way is to call `actor` with at least the Actor type. For example:
```lua
actor {
  Type = 'Quad',
  InitCommand = function(self)
    q = self
  end,
}
```
The second way is to use Gizmos. Gizmos are object oriented and allow for easier creation of Actors. Here is an example of creating a Quad Actor using the Rect Gizmo:
```lua
q = Rect:new()
```
Either method will give you the same result. You can now manipulate the Actor as you please.
```lua
q:SetSize(64, 64):Center()
```
Due to the global Lua variables used by Project OutFox, Actors and Gizmos do not share the same names. See the below table for a list of Gizmos and their corresponding Actors. Feel free to look within `include/gizmos.lua`.
| Actor Name | Gizmo Name |
| ----- | ----- |
| Actor | Gizmo |
| ActorFrame | Container |
| ActorFrameTexture | RenderTarget |
| ActorMultiTexture | MultiImage |
| ActorMultiVertex | Polygon |
| ActorProxy | Proxy |
| ActorScreenTexture | Viewport |
| ActorSound | Audio |
| BitmapText | Label |
| Text | TTFLabel |
| Model | Model3D |
| NoteField | PlayField |
| Quad | Rect |
| Sprite | Image |
| AudioVisualizer | WaveForm |
| N/A | ShaderLoader |
| N/A | FakePlayer |
| N/A | Input |

### Plugins in Ichigo
Plugins are great for quick, global functions that are user made. They are wrapped inside the `ichi` environment. Here's a simple plugin that creates a black background:
```lua
function black_bg()
  actor {
    Type = 'Quad',
    InitCommand = function(self)
      self:FullScreen():diffuse(0, 0, 0, 1)
    end,
  }
end
```
You can define more than one global function in a plugin.

### Classes in Ichigo
If you've used classes in other languages before, this should be a straightforward process. A brief example of classes looks like this:
```lua
-- a load blocker; if we already have it, don't continue
if Example then return end

-- base class
class 'Example' {
  Field = 'foo',
  Method = function(self) return self.Field end, -- 'foo'
}

-- derived cass
class 'Example2' : extends 'Example' {
  NewField = 'bar',
  Method = function(self) return self.Field..self.NewField end, -- 'foobar'
}
```
You can also take a look at `example.lua` in `include`. Once you have written your class, you can include and use it like so:
```lua
include 'example' -- include/example.lua

local e2 = Example2:new()
print(e2:Method()) -- foobar
```

### Libraries in Ichigo
Libraries are a great way to extend the functionality of Ichigo Template. They are not protected inside of the `ichi` environment, but instead add to it, defining variables and functions that source files will use. Here's a short example of a library:
```lua
-- this grabs the ichi environment
local ichi = ...
-- here we add to ichi like so
function ichi.MyLibraryFunction()
  print('My Ichigo Library')
end
-- you can also return actors
return Def.Actor {
  OnCommand = function(self) print('hewo') end
}
```
You can then use the function in your `main.lua` by calling `MyLibraryFunction()`. The best example of a library written for Ichigo would be the standard library (`lib/std.lua`).


## Tips to Keep Your Files Clean
- Do all of your work within the `src` folder.
- Setup goes in `main.lua`. Actors and Gizmos go in `layout.lua`. Gimmicks go in `gimmicks.lua`.
- Make use of the `init`, `ready`, and `update` functions when necessary.
- Keep all class definitions in the `include` folder and include them with the `include` keyword.
- Keep all libraries in the `lib` folder. They autoload from there.
- Likewise, keep all plugins inside `src/plugins`. They are also autoloaded.
- `include` at the top of the file. `run` at the bottom.
- If you plan to write code that other files will depend on, consider a library or an include file.
- If your code requires a library, do not write it as a library. Libraries should not depend on anything other than the `ichi` environment table passed to them. Consider a class or a plugin instead.
- Don't be afraid to ask me any questions! You can contact me (Sudospective) in the Project OutFox Discord server.
