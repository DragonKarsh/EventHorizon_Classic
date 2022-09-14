# EventHorizon_Classic
EventHorizon rewrite for World of Warcraft Classic

![WowClassic_pIA5SsLFbN](https://user-images.githubusercontent.com/51246270/189513050-77f681ad-6e9b-479e-a37b-6db910589631.gif)

## What does it do?

EventHorizon is an ability/aura tracker that displays everything in an accurate common timeline and provides many indications such as:
* Future damage/heal ticks
* Recast advisor
* GCD indicators

And more...

## What does it do to your gameplay?

EventHorizon by default lets you see the events slide into the past.  
This alone gives you an immediate feedback as to how well you timed a cast, refreshed an ability, did not clip a dot tick etc.  

You no longer need to go dig your logs to find how efficient your execution was and can improve during the encounter itself.  

## Main Elements

![image](https://user-images.githubusercontent.com/86252474/190220515-61611a11-d4f0-427a-a835-1cc27d2a38ea.png)

* `A` : "Now" reference. Everything to the left of it is considered in the past.
* `B` : Recast advisory. The point you should start casting for the aura to apply right when the previous one ends (Anti clipping).
* `C` : Damage/Heal tick markers.
* `D` : Aura duration.
* `E` : Cast/Channel duration.
* `F` : Cooldown duration.

>#### Slash Commands

| command                          | description                |
| :------------------------------- | :------------------------- |
| `/eh` , `/evh` , `/eventhorizon` | Opens the options window   |
| `/eh profiles choose <name>`     | Switch to profile `<name>` |
