# tides & floods - Work in Progress

# How to use

In its current state, the tide level has to be changed with the /tide [height] command.
Raising or lowering the sea level by more than one node is possible, but not necessarily the goal of the mod.


# Goal

The goal of this mod is to make simulation of water level rising and lowering in realtime in a visually pleasant way.
It uses multiple liquid nodes :
- seawater : the main water node that fills the ocean. Doesn't contain any ABM.
- shorewater : a node generated where the sea meets the land. It contains a slow ABM that will start the receding tide process
- offshorewater : a node generated at the surface, at every cmapblock corner. It uses a slow ABM too trigger rising tides starting at the edge of the map (when it neighbours a "ignore" node)
- waves : a flowing liquid node with a fast ABM that takes care of everything inbetween and disappear once it is finished.

Some of those nodes contain an LBM so loading mapblocks will "catchup" instantaneously to to current sea level

# To Do

- fix node names
- re-implement naturally occurring tides
- save tide level per world
- replace water during terrain gen (still keep LBMs to support already loaded worlds)
- tweak texture colors
- re-implement filling "pools" that stays filled at low tide
- improve river connections?
- handle vegetation
- handle floating things (I'll probably directly edit things like lilypads so they fall, but then they have to float upward somehow)
- fix liquid swimming physics
- find what I am missing
- make all water nodes work with the bucket
- create new seawater node not affected by tides
- change command /tide to /sealevel?

# Futur plans

- adapt mod for lava and eruptions
- make it work with dynamic liquid?
