# Truckee Trash iOS App

This is the iOS application for Truckee Trash, built with SwiftUI and Tuist.
For web application instructions see [the root README](../README.md).


## Features

- **Main Screen**: Displays pickup information for your next selected pickup day
- **Settings**: Configure your preferred pickup day (Monday-Friday) and notification preferences
- **Push Notifications**: Get reminded the evening before your pickup day with specific content
- **Widget**: Shows the current/next service week status on your home screen
- **API Integration**: Connects to the deployed web app at https://truckee-trash.vercel.app

## Architecture

The app is structured as a modular Tuist project with the following targets:

### TruckeeTrashKit
Core framework containing:
- **Models**: Data structures for API responses (`DayPickupInfo`, `RelevantWeekStatusInfo`)
- **API Client**: Network layer for communicating with the backend
- **Utilities**: Date utilities for Truckee timezone handling

### SettingsFeature
- Settings UI for pickup day selection
- Notification preferences management
- UserDefaults integration

### NotificationsService
- Local notification scheduling and management
- Smart notification content based on pickup type
- Permission handling

### TruckeeTrashWidget
- iOS widget displaying current/next week status
- Timeline provider for automatic updates
- Small and medium widget sizes supported

### Main App
- SwiftUI ContentView showing next pickup day info
- Integration with all framework modules
- Launch screen and app configuration

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ deployment target
- Tuist (for project generation)

### Setup
1. Install Tuist: `curl -Ls https://install.tuist.io | bash`
2. Navigate to the ios directory: `cd ios`
3. Generate the Xcode project: `tuist generate`
4. Open `TruckeeTrash.xcodeproj` in Xcode
5. Build and run the project

### Configuration
The app is pre-configured to connect to the deployed backend at `https://truckee-trash.vercel.app`. No additional configuration is needed.

## Key Components

### API Integration
- All API calls use the deployed Vercel URL
- Proper timezone handling for Truckee (America/Los_Angeles)
- Error handling and retry logic

### User Experience
- **Main Screen**: Shows next occurrence of user's selected pickup day
- **Smart Notifications**: Content varies based on pickup type (recycling, yard waste, trash only)
- **Widget**: Displays relevant service week status with color coding
- **Settings**: Easy pickup day selection (Monday-Friday only)

### Notification Strategy
The app uses a hybrid approach for notifications:
1. Fetches actual pickup type for the next pickup day
2. Schedules notification with specific content
3. Falls back to generic message if API call fails
4. Automatically reschedules when settings change

## Testing
- Unit tests for TruckeeTrashKit components
- API client testing with date formatting/parsing
- Date utility testing for weekday calculations

## Widget Implementation
- Uses TimelineProvider for automatic updates
- Updates daily or at end of service week
- Shows current week status with special pickup information
- Supports small and medium widget families
