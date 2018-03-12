= OCaml Solution

== Building and running

Build the program with

`jbuilder build lgir.exe` 

Then run it:

`./_build/default/lgir.exe`

== Logic

This OCaml solution works as follows -- let's use the `[5; 1; 2; 3; 0]` list as an example:

1) "Tag" the list element with their respective position:

`[(5,0); (1,1); (2,2); (3,3); (0,4)]`

2) Break the list into sublists whenever the element value decreases:

`[[(5,0)]; [(1,1); (2,2); (3,3)]; [(0,4)]]`

3) Take the longest list:

`[(1,1); (2,2); (3,3)]`

4) Extract the indexes of the first and last element

`(1,3)`

5) Done!