# Get Recent Wolfram Mathematica Documents for LaunchBar

This repository provides an action for [LaunchBar](https://www.obdev.at/products/launchbar/actions.html) for accessing recent documents opened with [Wolfram Mathematica](https://www.wolfram.com/mathematica/). The actions are designed to streamline access to recent files for users of Wolfram Mathematica.

<img alt="Screenshot" src="Images/Wolfram_Mathematica_screenshot.jpg" width="1108">

## Contents

This repository includes the following components:

- **Actions**: Pre-packaged LaunchBar action in `Action.zip` to enable direct access to recent documents.
- **Source Code**:
  - **GetRecentMathematicaDocuments**: Retrieves recent Wolfram Mathematica documents.
  
## Installation

### Option 1: Manual Installation

1. **Download** the pre-packaged action from the [Action.zip](https://github.com/alberti42/Get-Recent-Mathematica-Documents-For-LaunchBar/raw/refs/heads/main/Action.zip).
2. **Extract** the contents, which include:
   - `Recent Wolfram Mathematica Documents.lbaction`
3. Place these `.lbaction` files into your LaunchBar Actions folder:
   ```
   ~/Library/Application Support/LaunchBar/Actions
   ```

4. **Restart LaunchBar** to load the new actions.

### Option 2: Automatic Installation

Alternatively, you can simply double-click each `.lbaction` file. This will automatically install the action in LaunchBar.

## Compilation Instructions

To compile the `GetRecentMathematicaDocuments` program from the source code, follow the steps below. Compilation from the source code should however not be necessary if you simply plan to use the actions.

1. **Open the Xcode project**:
   - Open the Xcode project `GetRecentMathematicaDocuments.xcodeproj`, which is located at the root of the project directory:
   ```
   open GetRecentMathematicaDocuments.xcodeproj
   ```

2. **Set Build Configuration**:
   - Go to **Edit Scheme** for each target and ensure the **Build Configuration** is set to `Release` for the final production build.

3. **Build the Selected Target**:
   - Select **Product > Build** to build the selected scheme. This will compile the program and place the output in the `BUILT_PRODUCTS_DIR`.

4. **Manual Copy to LaunchBar Actions**:
   - After building, copy the executable to the in:
     ```
     ~/Library/Application Support/LaunchBar/Actions/Recent Wolfram Mathematica Documents.lbaction/Contents/Scripts
     ```

## Usage

- Activate LaunchBar and type the name of Wolfram Mathematica.
- Tip: once you select `Wolfram` app in LaunchBar, you can press ⌥+⌘+a to associate a different string such as `Mathematica` if you prefer the old name.
- Press space to display the recent documents directly from LaunchBar.

## Tips

It is convenient to increase the number of recent documents tracked by Mathematica with the command:

```Mathematica
SetOptions[$FrontEnd, "NotebooksMenuHistoryLength" -> 100] 
```

## Donations

If you find this plugin helpful, consider supporting its development with a donation.

[<img src="Images/buy_me_coffee.png" width=300 alt="Buy Me a Coffee QR Code"/>](https://buymeacoffee.com/alberti)

## Author

- **Author:** Andrea Alberti
- **GitHub Profile:** [alberti42](https://github.com/alberti42)
- **Donations:** [![Buy Me a Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20a%20Coffee-orange)](https://buymeacoffee.com/alberti)

Feel free to contribute to the development of this plugin or report any issues in the [GitHub repository](https://github.com/alberti42/obsidian-plugins-annotations/issues).
