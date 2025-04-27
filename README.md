# 📱 Mazaady iOS App

An iOS application that displays a user profile, searchable product list, and categorized content like advertisements and tags. Built using **MVVM-C** and **Clean Architecture**, this app showcases modern iOS development with responsive UI, offline caching, and localization support.

---

## 🔧 Features

- ✅ User profile with name and avatar
- ✅ Tab-based navigation (Products, Reviews, Followers)
- ✅ Real-time product search with keyword filtering
- ✅ Product listing with:
  - Image, name, price
  - Countdown timer for product end date
  - Special offer labels
- ✅ Ads list and tags display
- ✅ Offline support using Realm
- ✅ Dark Mode & multi-language support
- ✅ Handle multiple environment (staging and release)
---

## 🧱 Architecture Overview

### MVVM-C with Clean Architecture

This app adopts a **hybrid architecture** combining:

- **MVVM-C (Model-View-ViewModel-Coordinator)**: Ensures separation of navigation logic using Coordinators and keeps ViewModels focused on state and business handling.
- **Clean Architecture**: Separates concerns across layers — `Presentation`, `Domain`, and `Data`.

## 🚀 Getting Started

### Requirements

- Xcode 15+
- Swift 5.9+

### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/mazaady-ios.git
cd mazaady-ios
