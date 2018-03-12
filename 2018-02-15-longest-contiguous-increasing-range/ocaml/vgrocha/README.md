OCaml Solution
==============

Building and running
--------------------

Build the program with

`jbuilder build lgir.exe` 

Then run it:

`./_build/default/lgir.exe`

Logic
-----

This OCaml solution works as follows -- let's use the list `[5; 1; 2; 3; 0]` as an example:

1) "Tags" the list elements with their position index:

   `[(5,0); (1,1); (2,2); (3,3); (0,4)]`

2) Breaks the list into sublists whenever the next element value decreases:

   `[[(5,0)]; [(1,1); (2,2); (3,3)]; [(0,4)]]`

3) Gets the longest list:

   `[(1,1); (2,2); (3,3)]`

4) Extracts the indexes of the first and last element: 

   `(1,3)`

5) Done!
