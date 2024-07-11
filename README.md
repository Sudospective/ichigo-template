# Ichigo Template
###### Created by Sudospective


## What is Ichigo Template?
Ichigo Template (イチゴ) is a gimmick template for Project OutFox powered by the in-engine PandaTemplate. You can think of it as the base PandaTemplate with some extra features included.


## What features does the template have?
Ichigo Template allows you to not only streamline your gimmick creation process, but it also provides simple-to-use tools for complex features like classes and objects. Ichigo Template can be used for normal gimmick files, minigames, etc. The only limits are the ones you set yourself! Ichigo Template is also fully encapsulated in its own local environment that is garbage collected after a screen change, so you can be sure that nothing is leaked once the template is no longer in use by the engine. No more pesky globals hanging around after a gimmick file is finished, not a single one!


## Getting Started
Documentation is available [here](https://ichigo-docs.sudospective.net).


## Tips to Keep Your Files Clean
- Do all of your gimmick related work within the `/src` folder.
- Setup goes in `main.lua`. Actors and Gizmos go in `layout.lua`. Gimmicks go in `gimmicks.lua`.
- Make use of the user-defined hooks (`init`, `ready`, `update`, etc.) when necessary.
- Keep all class definitions in the `/include` folder and include them with the `include` method.
- Keep all libraries in the `/lib` folder. They autoload from there.
- Likewise, keep all plugins inside `/src/plugins`. They are also autoloaded.
- `include` at the top of the file. `run` at the bottom.
- If you plan to write code that other files will depend on, consider a library or a header.
- If your code depends on a library, do not write it as a library. Libraries should not depend on anything and serve only to extend the ichi environment table passed to them. Consider a header or a plugin instead.
- Don't be afraid to ask me any questions! You can contact me (Sudospective) in the Project OutFox Discord server.
