Comp3410
========

Repository for MIPS project

MIPS Mansion was the final result of my group's project in COMP 3410 (Computer Organization and Assembler Language) at the University of Memphis in the Spring 2014 semester. The members of this group (dubbed "Team Puzzle" by our professor) were (in alphabetical order by last name):
1. Nathan Brandeburg
2. Joseph Ciskowski
3. Drew Stabenow
4. Daniel Wood
5. Jonathan Wood (Hey, that's me! Woohoo!)

It is a Zork-like text-based maze/adventure game written entirely in the MIPS Assembler language. To complete this project, we had to learn/figure out how to perform what are usually a few basic tasks:
1. File reading - in most high-level languages, file reading is a relatively simple task. In MIPS, it's not too bad, but parsing out the information from files can be a bit...tricky.
2. String concatenation - in most high-level languages, this is laughably simple. We had to use this to build dynamic filenames for each room and, while it was far more painful than we hoped it would be, being able to do this made MIPS Mansion a heck of a lot more impressive.
3. Dynamic input validation - depending on the "room" you are in within the mansion, different inputs might be valid, and each input will have a different result. As such, we had to be able to read in any and all possible inputs to verify whether the user's actual input is acceptable and, if so, what the result might be (usually just the number of the next room, but there were also some "unique" results as well).

One last note: we were only able to consistently get this code to compile and run using the Mars MIPS simulator in Linux Mint (tested in versions 14 and 16) and Windows 7. If any changes are made to the code (which they may be if I get bored), this post will be modified with the changes, and it will only be after they are confirmed in these operating systems.

So, with no further ado, I present the MIPS Mansion source code. Enjoy!
