# tides & floods - Work in Progress

# How to use

In its current state, the tide level has to be changed with the /sealevel [height] command.
Raising or lowering the sea level by more than one node is possible, but not necessarily the goal of the mod.


(previously the command was /tide, now it is /sealevel)


https://user-images.githubusercontent.com/27686967/181780041-55fcae91-813f-4605-8ac4-0f45167a755d.mp4


# Goal

The goal of this mod is to make simulation of water level rising and lowering in realtime in a visually pleasant way.
It uses multiple liquid nodes :
- seawater : the main water node that fills the ocean. Doesn't contain any ABM.
- shorewater : a node generated where the sea meets the land. It contains a slow ABM that will start the receding tide process
- offshorewater : a node generated at the surface, at every cmapblock corner. It uses a slow ABM too trigger rising tides starting at the edge of the map (when it neighbours a "ignore" node)
- waves : a flowing liquid node with a fast ABM that takes care of everything inbetween and disappear once it is finished.

Some of those nodes contain an LBM so loading mapblocks will "catchup" instantaneously to to current sea level



https://user-images.githubusercontent.com/27686967/181780172-42193b2a-f621-4290-a7fa-0ac9d0f1ff4f.mp4



# To Do

## first
- replace water during terrain gen (still keep LBMs to support already loaded worlds)
- re-implement filling "pools" that stays filled at low tide
## next
- fix liquid swimming physics
- handle vegetation
- handle floating things (I'll probably directly edit things like lilypads so they fall, but then they have to float upward somehow)
- re-implement naturally occurring tides
## later
- tweak texture colors
- improve river connections?
- make all water nodes work with the bucket
- create new seawater node not affected by tides



https://user-images.githubusercontent.com/27686967/181776097-257afdd9-03cc-4dd6-96d9-9ea23b6b80a6.mp4


# Futur plans

- adapt mod for lava and eruptions
- make it work with dynamic liquid?
