
# Game Engine for Tetris

This project is a part of the course CS F363 - Compiler Construction at BITS Pilani, Goa Campus.
It consists of a scanner and a parser which translates instructions to a python code. The game engine is a modification of an old implementation done .

## Features
- Initial height and width of the game window is **16x8**
- **Customizations**
    - **Screen size:** Can change screen size along with the cell size
    - **Speed-Up/Slow-Down:** Change the spped of the game
    - **Increase difficulty:** By increasing input delay, the game gets more difficult


# Instructions

Run the following command to generate the parser and scanner files.

```bash
make
```

Run the following command to directly generate the python code from the two input file.

```bash
make run
```

Then, run out1.py or out2.py to run the game.
```bash
python3 out1.py
```

Clean:
```bash
make clean
```
# Input

Input file must be divided into three sections. Section1 containing variable declarations, Section2 has function declarations and Section3 has the main function.

Please follow space conventions as mentioned in the input files.