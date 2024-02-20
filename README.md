# Ichigo Template
###### Created by Sudospective


## What is Ichigo Template?
Ichigo Template is a gimmick template for Project OutFox powered by the in-engine PandaTemplate. You can think of it as the base PandaTemplate with some extra features included.


## What features does the template have?
Ichigo Template allows you to not only streamline your gimmick creation process, but it also provides simple-to-use tools for complex features like classes and objects. Ichigo Template can be used for normal gimmick files, minigames, etc. The only limits are the ones you set yourself! Ichigo Template is also fully encapsulated in its own local environment that is garbage collected after screen changes, so you can be sure that nothing is leaked once the template is no longer in use by the engine. No more pesky globals hanging around after a gimmick file is finished, not a single one!


## Getting Started

### Template Variables
| Name | Description |
| - | - |
| Players | Shorthand enums for players (ex: "P1") |
| Options | PlayerOptions for players |
| Actors | Table Containing all actors (ex: Actors.P1) |
| SONG | Current Song object |
| SONG_POS | Song Position object |
| SRC_ROOT | Source Root ("/Songs/Pack/Song/src") |

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
Due to the global Lua variables used by the game, Actors and Gizmos do not share the same names. See the below table for a list of Gizmos and their corresponding Actors:
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
| N/A | ShaderLoader |
| N/A | FakePlayer |
| N/A | Input |

### Classes in Ichigo
If you've used classes in other languages before, this should be a straightforward process. A brief example of classes looks like this:
```lua
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
You can also take a look at `example.lua` in `src/include`.

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
You can then use the function in your `main.lua` by calling `MyLibraryFunction()`.


## Tips to Keep Your Files Clean
- Do all of your work within the `src` folder.
- Setup goes in `main.lua`. Actors and Gizmos go in `layout.lua`. Gimmicks go in `gimmicks.lua`.
- Make use of the `init`, `ready`, and `update` functions when necessary.
- Keep all class definitions in the `src/include` folder and include them with `include`.
- Keep all libraries in the `lib` folder. They autoload from there.
- `include` at the top of the file. `run` at the bottom.
- Don't be afraid to ask me any questions! You can contact me (Sudospective) in the Project OutFox Discord server.
- If you plan to write code that other files will depend on, consider a library or an include file.
- If your code requires a library, do not write it as a library. Libraries should not depend on anything other than the ichi environment handed to them.
