# 📖 Rateel (رَتِّلِ) - Interactive Tajweed Learning App

<div align="center">
  <img src="src/assets/icons/android-chrome-192x192.png" alt="Rateel Logo" width="120"/>
  <h3>Learn Tajweed Rules with an Immersive Experience</h3>
</div>

## 📋 Overview

**Rateel** is a comprehensive Tajweed learning application focused on teaching Quranic recitation rules through interactive lessons, practice exercises, and audio/video content. Built with Angular and transformed to mobile platforms via Capacitor, Rateel offers a consistent learning experience across devices.

The name "Rateel" (رَتِّلِ) comes from the Quranic command meaning "recite [the Quran] with measured rhythmic recitation," emphasizing the app's focus on proper Quranic recitation.

## 🌟 Key Features

- **📚 Structured Learning Path**: Progressive courses from beginner to advanced
- **🎯 Interactive Lessons**: Various lesson types (video, reading, practice, listening)
- **🎤 Recitation Practice**: Audio recording and playback for self-assessment
- **🔍 Tajweed Highlighting**: Visual highlighting of specific recitation rules
- **📱 Cross-Platform**: Works on web and mobile (Android/iOS) via Capacitor
- **🌙 Islamic-Inspired UI**: Beautiful interface with Islamic design elements
- **🔄 Offline Support**: Full functionality without requiring constant internet
- **📊 Progress Tracking**: Comprehensive tracking of user achievements
- **🌐 Right-to-Left (RTL) Support**: Fully compatible with Arabic text direction

## 🏗️ Technical Architecture

The app is built using a modular architecture with the following components:

### Core Technologies
- **Angular 19**: Primary frontend framework
- **Capacitor 6**: Framework to convert web app to native mobile
- **SCSS**: Enhanced styling with variables and mixins
- **RxJS**: Reactive state management

### Project Structure
```
src/
├── app/
│   ├── core/             # Core services and utilities
│   ├── features/         # Feature modules (courses, lessons, units)
│   ├── layout/           # Main layout components
│   └── shared/           # Shared components, directives, interfaces
├── assets/               # Static assets
│   ├── data/             # JSON data files (courses, lessons, etc.)
│   ├── audio/            # Audio files for pronunciation
│   └── icons/            # App icons
└── styles/               # Global styles
```

### Key Modules
- **Courses Module**: Browse and select learning courses
- **Units Module**: Units within each course 
- **Lessons Module**: Individual interactive lessons
- **Core Module**: Shared services for storage, platform, etc.

## 🔄 Angular to Mobile Transformation

Rateel uses Capacitor to transform the Angular web app into mobile applications:

1. **Web-First Development**: Core functionality built with Angular
2. **Capacitor Integration**: Native capabilities (audio recording, haptics)
3. **Platform-Specific Adjustments**: UI adaptations for mobile devices
4. **Optimized Performance**: Enhanced for mobile with smooth animations

### Mobile-Specific Features
- **Voice Recording**: Native audio capabilities for pronunciation practice
- **Haptic Feedback**: Tactile response during interactions
- **Orientation Control**: Landscape mode for optimal content viewing
- **Mobile Gestures**: Swipe, tap, and drag interactions

## 🛠️ Getting Started

### Prerequisites
- Node.js 18+
- npm 9+
- Angular CLI 19

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/rateel.git
cd rateel

# Install dependencies
npm install

# Serve web application
npm start
```

### Building for Mobile

```bash
# Build for production
npm run build:mobile

# Prepare Android build
npm run build:android

# Run on iOS
npm run capacitor:run:ios
```

## 📱 Mobile Development

Capacitor is used to wrap the Angular application for deployment to mobile platforms:

```bash
# Add platforms
npx cap add android
npx cap add ios

# Sync changes after building
npx cap sync

# Open native projects
npx cap open android
npx cap open ios
```

## 🧩 App Features Detail

### Course System
- Structured courses with progressive difficulty
- Units with themed content
- Varied lesson types for engaging learning

### Lesson Types
- **Video Lessons**: Instructional videos on Tajweed concepts
- **Reading Lessons**: Text-based explanations with highlighted rules
- **Interactive Practice**: Practice pronunciation with feedback
- **Audio Lessons**: Listen to expert recitation examples

### Tajweed Rules Coverage
- Noon and Meem Mushaddad (النون والميم المشددتان)
- Noon Sakinah and Tanween (النون الساكنة والتنوين)
- Meem Sakinah (الميم الساكنة)
- Various types of Madd (المد)

# Navigation Flow

## Lesson Completion Flow
1. User completes a lesson (via progress or skip button)
2. **First-time completion**: Show completion animation on lesson card (1.5s)
3. **Subsequent completions**: Skip animation, use shorter delay (0.5s)
4. Automatically navigate:
   - If more lessons in unit → Next lesson
   - If last lesson → Unit list page with completion parameter

## Unit Completion Flow
1. Unit list receives completion parameter
2. **First-time completion**: Show unit card completion animation (1.5s)
3. **Subsequent completions**: Skip animation, use shorter delay (0.5s)
4. Automatically navigate:
   - If more units in course → First lesson of next unit
   - If last unit → Course list page

## Key Requirements
- Animations ONLY on first-time completions
- Consistent delays (1.5s with animation, 0.5s without)
- Automatic navigation after delay
- Proper state tracking to prevent duplicate animations
- Navigation should follow proper unit/lesson order

## 🎨 Design Elements

Rateel features an Islamic-inspired design with:
- Emerald green primary color scheme
- Gold accents inspired by mosque decorations
- Glass-effect UI elements
- Traditional Islamic patterns and motifs

## 🧪 Testing

```bash
# Run tests
npm test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- Special thanks to all contributors
- Inspiration from traditional Tajweed learning materials
- Font Awesome for icons
- Angular and Capacitor teams for excellent frameworks