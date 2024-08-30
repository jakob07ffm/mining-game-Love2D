# Mining Game

Welcome to Mining Game! This game is built using the LÖVE framework (Love2D) and features mining, crafting, base building, and combat. Below you'll find information on how to play the game, its features, and how to get started.

## Features

- **Mining**: Mine various types of blocks with different durability and values.
- **Crafting**: Create tools and structures using resources you gather.
- **Base Building**: Construct and upgrade your base to restore health and resources.
- **Enemies**: Fight against different types of enemies, including melee, ranged, and special enemies with unique abilities.
- **Weather and Day-Night Cycle**: Experience changing weather conditions and a day-night cycle that affects gameplay.
- **Quests**: Complete quests for rewards and progress in the game.
- **NPCs**: Interact with NPCs to receive help or trade items.

## Controls

- **Movement**: 
  - `W`: Move up
  - `S`: Move down
  - `A`: Move left
  - `D`: Move right
- **Mining**: 
  - `M`: Mine the block in front of you
- **Tool Crafting**:
  - `C`: Craft a pickaxe if you have enough resources
- **Building Base**:
  - `B`: Build a base (if resources allow)
- **Torch Management**:
  - `T` or `F`: Place a torch if you have coal
- **NPC Interaction**:
  - `I`: Toggle NPC interaction
- **Trading**:
  - `R`: Trade iron for gold (if enough iron is available)
- **Upgrade**:
  - `U`: Upgrade mining power if you have enough score
- **Attack**:
  - `K`: Attack (functionality to be implemented based on your game logic)
- **Score Increase**:
  - `S`: Increase player score by 10

## Setup

1. **Install LÖVE (Love2D)**:
   - Download and install LÖVE from [the official website](https://love2d.org/).

2. **Run the Game**:
   - Place your game files in a directory.
   - Run the game by dragging the directory onto the LÖVE executable or by using the command line:
     ```sh
     love path/to/your/game/directory
     ```

## Game Mechanics

### Mining

- Use the `M` key to mine blocks.
- Different block types include stone, coal, gold, diamond, iron, silver, and wood.
- Each block type has its own durability and value.

### Crafting

- Craft tools and structures using resources from your inventory.
- Recipes for crafting tools and structures are predefined.

### Base Building

- Build a base by pressing `B` when you have enough resources.
- A base will restore your health, hunger, and stamina when you are within its vicinity.

### Enemies

- Enemies include melee, ranged, and special types.
- Melee enemies can attack you when close, while ranged enemies attack from a distance.
- Special enemies have unique abilities such as healing or buffing other enemies.

### Weather and Day-Night Cycle

- The game features different weather conditions like clear, rain, and storm.
- The day-night cycle affects visibility and player health during storms.

### Quests

- Complete various quests to earn rewards and advance the game.
- Quests are updated as you progress and meet their conditions.

## Development

Feel free to modify and extend the game! Contributions and improvements are welcome. To get started with development:

1. **Clone the Repository**:
   - Clone or download the repository to your local machine.

2. **Make Changes**:
   - Edit the Lua files as needed to implement new features or fix bugs.

3. **Test Your Changes**:
   - Run the game using LÖVE to test your modifications.

4. **Share Your Improvements**:
   - Share your changes or contribute to the project by creating a pull request.
