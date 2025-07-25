# SkillSync

SkillSync is a real-time skill-sharing platform built with Flutter and Firebase. It enables users to list their skills, search for others with complementary expertise, and initiate chat or call-based collaboration. The application aims to simplify knowledge exchange through intuitive UI and seamless communication features.

---

**Technologies & Tools used:**  
- **Flutter:** Cross-platform UI toolkit for building natively compiled apps.  
- **Firebase:** Backend services including Authentication, Firestore (database), Cloud Messaging (notifications), and Storage.  
- **BLoC Pattern:** For state management, ensuring a clean separation between business logic and UI.  
- **Figma:** Used for UI/UX design and prototyping before development.  
- **Git:** Version control with meaningful commit history.  
- **Dart:** Programming language for Flutter development.  

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Screens](#screens)
- [Setup Instructions](#setup-instructions)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Figma Design](#figma-design)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

SkillSync allows users to:

- Share skills they know.
- Search for people with specific skills.
- Send chat requests (with acceptance).
- Initiate real-time voice calls.
- Accept/decline chat or call invitations.

The app is designed for students, freelancers, and professionals seeking direct peer learning.

---

## Features

- Firebase Authentication
- Firestore Database Integration
- Skill Listing and Discovery
- Chat Request Flow
- Real-Time Voice Call Support (WebRTC-ready)
- BLoC State Management
- Modular and Testable Architecture

---

## Project Structure

lib/
│
├── bloc/ # Business logic components (auth, request, skill, search)
├── models/ # Data models (user_model, skill_model, chat_room, request_model)
├── repositories/ # Data interaction logic
│ ├── auth_repository.dart
│ ├── firebase_repository.dart
│ ├── request_repository.dart
│ └── skill_repository.dart
├── screens/ # UI screens
│ ├── add_skill_screen.dart
│ ├── auth_screen.dart
│ ├── chat_list_screen.dart
│ ├── chat_screen.dart
│ ├── home_screen.dart
│ ├── request_screen.dart
│ ├── search_screen.dart
│ ├── skill_list_screen.dart
│ └── splash_screen.dart
├── widgets/ # Reusable UI components
│ ├── category.dart
│ └── skill_card.dart
├── main.dart # Entry point


---

## Screens

- **Splash Screen** – App initialization
- **Authentication Screen** – Firebase-based sign-in
- **Home Screen** – Skill feed & profile actions
- **Search Screen** – Find users by skill
- **Skill List Screen** – All available skills
- **Add Skill Screen** – Post a new skill
- **Request Screen** – Chat and call invitations
- **Chat Screen** – Messaging interface
- **Chat List Screen** – All active chats

---

## Setup Instructions

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Bhuvanesh-S03/Skill-Sync.git
   cd skillsync



