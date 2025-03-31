Made By @Koutakou (koutakou@protonmail.com)

# Nym Status Widget

A macOS menu bar app that displays the current role of a Nym Mixnode and a Nym gateway by querying the Nym validator API every hours.

## Features

- Shows the current role status of the Nym Mixnode and the Nym gateway directly in the macOS menu bar
- Refreshes automatically every hours
- Manual refresh option in the dropdown menu

## Requirements

- macOS 11.0 or later
- Swift 5.5 or later
- Internet connection

## Building and Running

1. Replace "NODE_ID" occurence in main.swift and /PATH/TO in plist file

2. Open Terminal and navigate to the project directory:
   ```
   cd /PATH/TO/NymStatusWidget
   ```

3. Build the application:
   ```
   swift build
   ```

4. Run the application:
   ```
   swift run
   ```

## Usage

After launching, the app will appear in your menu bar, displaying the current role of the specified Nym Mixnode and the Nym gateway.
The status will automatically refresh every hour.

Click on the menu bar item to see options:
- "Refresh Now" - manually update the status
- "Quit" - exit the application
