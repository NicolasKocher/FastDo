# FastDo

A lightweight and intuitive todo list application for macOS that lives in your menu bar. FastDo helps you quickly capture tasks and organize them with natural language processing.

## Features

- **Menu Bar Integration**: Access your tasks instantly from the macOS menu bar
- **Natural Language Parsing**: Add tasks with due dates using natural language (e.g., "Buy groceries tomorrow", "Meeting Friday at 2pm")
- **Category Management**: Organize your tasks into customizable categories
- **Global Keyboard Shortcuts**: Quickly add tasks using configurable keyboard shortcuts
- **Smart Date Detection**: Automatically extracts and sets due dates from task descriptions
- **Launch at Login**: Option to start FastDo automatically when you log in
- **Clean, Native UI**: Beautiful SwiftUI interface that follows macOS design guidelines

## Installation on Mac

### Requirements
- macOS 12.0 or later
- Apple Silicon (M1/M2/M3) or Intel Mac

### Option 1: Download Pre-built App (Recommended)
1. Download `FastDo.dmg` from the releases section
2. Double-click the DMG file to mount it
3. Drag `FastDo.app` to your Applications folder
4. Launch FastDo from Applications or Spotlight
5. Grant necessary permissions when prompted (accessibility access may be required for global shortcuts)

### Option 2: Build from Source
1. **Install Xcode**: Download and install Xcode from the Mac App Store
2. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/FastDo.git
   cd FastDo
   ```
3. **Open in Xcode**:
   ```bash
   open FastDo.xcodeproj
   ```
4. **Build and run**: Press `Cmd + R` to build and run the application
5. **Archive for distribution** (optional):
   - Select `Product > Archive` in Xcode
   - Click "Distribute App" and choose "Copy App"

## Getting Started

1. **First Launch**: Click the FastDo icon in your menu bar (looks like a checkmark circle)
2. **Add a Task**: Type your task in the text field and press Enter
   - Try: "Call dentist tomorrow"
   - Try: "Team meeting Friday at 3pm"
3. **Create Categories**: Click the gear icon to manage categories and organize your tasks
4. **Set Keyboard Shortcut**: Go to Settings to configure a global shortcut for quick task entry
5. **Enable Launch at Login**: Toggle this option in Settings to start FastDo automatically

## Usage Tips

- Use natural language for due dates: "today", "tomorrow", "next week", "Friday", "in 2 hours"
- Categories help organize work vs personal tasks
- Completed tasks are automatically moved to a separate section
- Right-click tasks for additional options

## Technical Details

FastDo is built with:
- **SwiftUI**: For the native macOS user interface
- **KeyboardShortcuts**: For global hotkey support
- **LaunchAtLogin**: For automatic startup functionality
- **Natural Language Processing**: For intelligent date parsing

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.