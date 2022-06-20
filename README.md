# EventHorizon_Classic
EventHorizon rewrite for World of Warcraft Classic


I only play Shadow Priest, and have only implemented what I needed/wanted to play. You are more than welcome to fork and extend this implementation to include whatever you desire. I will not be providing any support for this though.

Conceptually, everything is the same as the original TBC/Wotlk version of this addon. There may be some changes required when hasted dots become a thing in Wotlk. However, there is very little code that I have reused. Part of this reason was because I wanted to learn more Lua, and so I attempted to challenge myself with some different concepts (which may or may not be completely bad). I also needed to make sure I understood the original code completely, which meant being able to reinterpret the code in my own way mattered a lot. I hope that what I have provided is an easier to maintain and follow codebase than the original, which also allowing for extensions to occur quicker and seamlessly.


You can now configure the main frame as well as add spells through the in-game options panel
/eventhorizon
/eh
/evh

![image](https://user-images.githubusercontent.com/51246270/174683475-a61c4362-8a27-4b52-9a66-8f2d4e307ae8.png)

To add a new spell, whether it is channeled, direct, or a dot, select the appropriate option and enter the SpellId (I recommend Rank 1) and press Okay. Then press the Create button to generate your new spell

![image](https://user-images.githubusercontent.com/51246270/174683737-93c6b05b-951b-4e45-8bcc-71ebed7d3a4c.png)

Once your spell is created, select it from the drop down and configure its order on the frame as well as any additional information needed (such as ticks for channels and dots). To disable this spell, click the Enabled checkbox to remove it from your spell frame

![image](https://user-images.githubusercontent.com/51246270/174683855-18a2e8e4-8bbf-42d0-8ba7-30b3d17f84bd.png)


