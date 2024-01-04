# Ichigo Template
###### Created by Sudospective


## What is Ichigo Template?
Ichigo Template is a gimmick template for Project OutFox powered by the in-engine PandaTemplate. You can think of it as the base PandaTemplate with some extra features included.


## What features does the template have?
Ichigo Template allows you to not only streamline your gimmick creation process, but it also provides simple-to-use tools for complex features like classes and objects. Ichigo Template can be used for normal gimmick files, minigames, etc. The only limits are the ones you set yourself! Ichigo Template is also fully encapsulated in its own local environment that is garbage collected after screen changes, so you can be sure that nothing is leaked once the template is no longer in use by the engine. No more pesky globals hanging around after a gimmick file is finished, not a single one!


## Getting Started

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
See the below table for a list of Gizmos and their corresponding Actors:
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
-- load blocker (keeps from loading file twice)
if Example then return end
-- base class
class 'Example' {
	Field = 'foo',
	Method = function(self) return self.Field end, -- returns 'foo'
}
-- derived cass
class 'Example2' : extends 'Example' {
	NewField = 'bar',
	Method = function(self) return self.Field..self.NewField end, -- returns 'foobar'
}
```
You can also take a look at `example.lua` in `src/include`.


## Tips to Keep Your Files Clean
- Do all of your work within the `src` folder.
- Setup goes in `main.lua`. Actors and Gizmos go in `layout.lua`. Gimmicks go in `gimmicks.lua`.
- Make use of the `init`, `ready`, and `update` functions when necessary.
- Keep all class definitions in the `src/include` folder and include them with `include`.
- `include` at the top of the file. `run` at the bottom.
- Don't be afraid to ask me any questions! You can contact me (Sudospective) in the Project OutFox Discord server.
