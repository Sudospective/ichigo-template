# Ichigo Template
###### Created by Sudospective

## What is Ichigo Template?
Ichigo Template is a gimmick template for Project OutFox powered by the in-engine PandaTemplate. You can think of it as the base PandaTemplate with some extra features included.

## What features does the template have?
Ichigo Template allows you to not only streamline your gimmick creation process, but it also provides simple-to-use tools for complex Lua features like classes and objects. Ichigo Template can be used for normal gimmick files, minigames, etc. The only limits are the ones you set yourself!

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
gimmick {16, 4, Tweens.easeOutElastic, 0, 1, function(p) print(p) end}
```
### Adding Actors in Ichigo
There are two ways to add actors in Ichigo. The first way is to call `actor` with at least the Actor type. For example:
```lua
actor {
	Type = 'Quad',
	OnCommand = function(self)
		self:SetSize(64, 64):Center()
	end,
}
```
The second way is to use Gizmos. Gizmos are object oriented and allow for easier creation of Actors. Here is an example of creating a Quad Actor using a Rect Gizmo:
```lua
local q = Rect:new()

function ready()
	q:SetSize(64, 64):Center()
end
```
Look in `gizmo.lua` inside the `src/include` folder for more Gizmos and which Gizmos give which Actors.
### Classes in Ichigo
Take a look at `example.lua` in `src/include`. This should give you a quick and dirty lesson on how classes work in Ichigo. An example of classes looks like this:
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
	Method = function(self) return self.Field .. self.NewField end, -- returns 'foobar'
}
```

## Tips to Keep Your Files Clean
- Do all of your work within the `src` folder.
- Setup goes in `main.lua`. Actors and Gizmos go in `layout.lua`. Gimmicks go in `gimmicks.lua`.
- Make use of the `init`, `ready`, and `update` functions when necessary.
- Keep all class definitions in the `src/include` folder and include them with `include`.
- Don't be afraid to ask me any questions! You can contact me (Sudospective) in the Project OutFox Discord server.
