# clonehero
Guitar Hero - Project, 
A custom implementation of Guitar Hero with FPGA and Python integration. 

Features:
- Two songs: Mississippi Queen and Linus & Lucy
- Real-time functionality: Score, streak, and multiplier tracking
- Reset game with 'R'
- Progress bar for gameplay feedback
- Menus: Main menu and end-game menu
- Audio integration: Python script reads UART signals from the FPGA for sound output
- Compatibility: Works with HDMI and keyboards available in the 385 Office Hour Room

Prerequisites:
1. Hardware:
 - Access to the FPGA and required peripherals.
2. Software:
 - Vivado
 - Vitus
 - Python (ensure it is installed on your system)
 - Windows PowerShell

Steps to Run the Project:
1. Setup the FPGA Project:
 - Download the .xpr zip file and extract it.
 - Create a new project in Vivado and import all source files and constraint files.
 - Add the user repository from Lab 6.
 - Export the hardware with the bitstream.
2. Setup in Vitus:
 - Open Vitus and use the workspace from Lab 6.2.
 - Update the workspace hardware with the files exported in step 1.
3. Prepare Python Environment:
 - Install the required Python libraries:
 pip install pygame pyserial
 - Download play.py.
 - Adjust the Python script to match the COM Port and Baud rate of the FPGA.
4. Run the Game:
 - In Windows PowerShell, navigate to the directory where play.py is located:
 cd path/to/play.py
 - Run the Python script:
 python play.py
 - Build and run the Vitus project, and you're ready to play!

Technologies Used:
- Vivado: FPGA synthesis and implementation
- Vitus: Embedded software development
- Python: Used for integrating sound and game functionality
- Libraries:
 - pygame: Game visuals and logic
 - pyserial: Communication with the FPGA
- Lab 6.2 Project: Provides base workspace and repository

Contributors:
- Arkaprabha Kolay
- William Mendez
