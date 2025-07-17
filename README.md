**Project Name:** Findom - Empowering Indian Citizens with Financial Knowledge

---

**Purpose:**
To develop a cross-platform Flutter application (Android + iOS) that provides simplified, real-time financial knowledge and CA-level insights for the common Indian citizen. The goal is to empower users with updated finance-related laws, tax tips, deadlines, business formation guides, and interactive tools without direct interaction with Chartered Accountants.

---

### 🏠 Target Users:

* Students
* Employees
* Small Business Owners
* Freelancers
* First-time Taxpayers
* Anyone curious about Indian finance

---

### 🚀 Key Features:

#### 1. **Home Feed: Real-time Finance Updates**

* Latest updates on:

  * Income Tax
  * GST
  * Business laws
  * RBI announcements
  * Union Budget
* Display via card-style scrolling feed

#### 2. **Modules**

* Income Tax Basics
* GST Explained
* Business Registrations (Proprietorship, LLP, Pvt Ltd)
* Investment & Mutual Funds
* TDS / 26AS / Form 16
* ITR filing simplified

#### 3. **Interactive Tools**

* Income Tax Calculator
* GST Calculator
* Due Date Tracker (with reminders)
* Choose your business type (quiz-based assistant)

#### 4. **Explainers with Illustrations**

* Carousel guides with basic financial terms
* Explainer videos
* Downloadable infographics

#### 5. **Findom Feed (Real-time Knowledge)**

* Connect to a backend that fetches:

  * CA-authored articles
  * Updated circulars from Income Tax, GST
  * YouTube or podcast content curated by experts
  * RSS or Webhook from ICAI & MCA websites

---

### 🧠 How Will Real-Time CA Knowledge Be Updated?

* Admin dashboard (Firebase CMS / Supabase / Strapi)
* Scrape or fetch updates via APIs (Govt sites)
* Schedule regular syncs via cron job (Node.js + Mongo/Firebase)
* Manual expert article uploads
* Verified content flagging

---

### 🎨 UI/UX Roadmap

* **Splash Screen** with animated logo
* **Onboarding** screens: What this app offers
* **Login/Sign-up** (Email + Google)
* **Home Feed** with personalized articles
* **Modules Page**: Topic-wise deep dives
* **Tools Tab**: Calculators and trackers
* **Reminders Page**: Custom tax deadlines, push notifications
* **Explore Section**: Video lessons & terms
* **Search**: Find topics easily
* **Settings**: Dark mode, language (Hindi/English), notifications

---

### 📱 App Screens Required

1. Splash Screen
2. Onboarding Carousel
3. Login/Signup
4. Home Feed (News/Updates)
5. Module List (Cards)
6. Module Detail (with collapsible sections)
7. Calculators Page (Input -> Output)
8. Reminder List (with calendar sync)
9. Explore (Video & Infographics)
10. Article Reader
11. Settings Page
12. Profile Page
13. Contact Us / Feedback
14. Error / No Internet Screen

---

### 🛠 GitHub Project Structure

```
ca_wisdom_app/
│
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── module_list_screen.dart
│   │   ├── module_detail_screen.dart
│   │   ├── calculator_screen.dart
│   │   ├── reminder_screen.dart
│   │   ├── explore_screen.dart
│   │   ├── settings_screen.dart
│   ├── widgets/
│   │   ├── custom_card.dart
│   │   ├── app_bar.dart
│   │   ├── bottom_nav.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── reminder_service.dart
│   ├── models/
│   │   ├── article_model.dart
│   │   ├── reminder_model.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── validators.dart
│   └── localization/
│       ├── en.json
│       ├── hi.json
│
├── pubspec.yaml
├── README.md
└── .gitignore
```
