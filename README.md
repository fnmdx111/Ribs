Ribs (or Ribs2D)
====

A 2D Ruby Interactive sand-Box Simulator. This is project is intended as the final project of W4167 Computer Animation.

How to Install
----

* Make sure you have Ruby 2.2.3+
* Install `libsdl2` (via brew for example)
* `gem install gosu`
* `gem install texplay -v 0.4.4.pre`

If you want to use the console

* Install `nanomsg` (via brew for example)
* `gem install nanomsg`
* The console and Ribs communicate through TCP sockets at 21556, make sure this port is open


Supported Interactions
----

+ **Left click**: select a particle, or unselect by hitting freespace
+ **Right click**: unselect a particle
+ **Space**: pause the simulation
+ **Backspace**: remove the selected particle
+ **D**: drag selected particle (and observe how the rest of the system runs!)
+ **S**: add a new spring force between the two selected particles
+ **G**: add a new simple gravity force in the scene by clicking freespace twice for the gravity vector
+ **P**: add a new particle by clicking freespace twice for the initial velocity
+ **Q**: quit Ribs
+ **F**: fix the selected particle (remove any forces applied to it), the velocity remains the same
+ **L**: lock the selected particle, same as fix, except that the velocity of the particle is set to 0 as well
+ **C**: circularly change collision detection and handling to Penalty, SimpleImpulse, and NoCollision
+ **E**: add a new edge between the two selected particles
+ AND MORE WILL BE ADDED!

Console Interactions
----

Run `client.rb` to interact with Ribs in a console (via NanoMsg)! Supported commands are:

+ **coll penalty k**: set penalty k value
+ **coll penalty thickness**: set penalty thickness value
+ **coll simple cor**: set simple handler COR value
+ **q!**: quit the console
+ **quit**: quit both the console and Ribs
+ **simp grav new**: new simple gravity force
+ **simp grav gravity=**: set gravity force gravity value
+ **spring new**: new spring force
+ **spring k=**: set spring force k value
+ **spring b=**: set spring force b value
+ **spring start=|end=**: set spring force start particle or end particle
+ **spring l0=**: set spring force l0 value
+ **spring spring color=**: set spring force spring color
+ **force remove**: safely remove a force
+ **edge new**: new edge
+ **edge start=|end=**: set edge start particle or end particle
+ **edge color=**: set edge color
+ **edge radius=**: set edge radius
+ **par new**: new particle
+ **par remove**: safely remove a particle
+ **par pos=|vel=|mass=|radius=|color=|fix|lock**: set various particle features
+ **list forces|par|edges**: list forces, particles, or edges
+ **show penalty|simple_coll**: show penalty force information or simple impulse handler information
+ **coll change**: change collision handler type
+ **pause**: pause or continue simulation


Dependencies
----

+ Gosu
+ TexPlay

Screenshot
----

![screenshot](sshot.png)

Author
----

Zihang Chen (zc2324)

License
----

This project is licensed under LGPL.
