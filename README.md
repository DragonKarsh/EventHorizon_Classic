# EventHorizon_Classic
EventHorizon rewrite for World of Warcraft Classic


I only play Shadow Priest, and have only implemented what I needed/wanted to play. You are more than welcome to fork and extend this implementation to include whatever you desire. I will not be providing any support for this though.

Conceptually, everything is the same as the original TBC/Wotlk version of this addon. There may be some changes required when hasted dots become a thing in Wotlk. However, there is very little code that I have reused. Part of this reason was because I wanted to learn more Lua, and so I attempted to challenge myself with some different concepts (which may or may not be completely bad). I also needed to make sure I understood the original code completely, which meant being able to reinterpret the code in my own way mattered a lot. I hope that what I have provided is an easier to maintain and follow codebase than the original, which also allowing for extensions to occur quicker and seamlessly.


To adjust your config, check out Init.lua

Here you can set how big you want the frame to be, as well as what spell you want to use as the GCD lookup
![image](https://user-images.githubusercontent.com/51246270/174459347-8d216925-40bb-4353-b214-6301a06c1688.png)

Here you can build the frame as a specific profile. As I mentioned, only Shadow Priest is implemented. You can configure your talent, gear, and race which affects this profile's framing

![image](https://user-images.githubusercontent.com/51246270/174459411-72847b0e-4b9c-412a-b776-0722f4681e87.png)
