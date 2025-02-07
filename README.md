# Currency Exchange App

## Project Overview

The Currency Exchange App is a mobile application designed to function as a digital currency exchange office. Users can create accounts, fund their wallets, check exchange rates, and perform currency transactions. The system consists of a mobile app, a web service, and a database.

## Features & Requirements

### Mobile Application

- User authentication (Sign Up, Login, Logout)
- Virtual wallet funding (simulated transactions)
- Fetch real-time exchange rates from the National Bank of Poland's API
- View archived exchange rates
- Perform currency exchange transactions (buy/sell currency)

### Web Service (SOAP/REST)

- Business logic for currency exchange operations
- Integration with the National Bank of Poland API ([https://api.nbp.pl/](https://api.nbp.pl/)) to fetch exchange rates
- Transaction processing

### Database

- Storage of user profiles and credentials
- Storage of transaction history
- Storage of user's currency balances

## Tech Stack

- Mobile Application: Flutter (Dart)
- Web Service: Node.js with Express (REST API)
- Database: MongoDB
- Authentication: Firebase Authentication

## System Design

### Functional & Non-Functional Requirements

#### Functional Requirements:

1. Users can register and log in.
2. Users can view real-time exchange rates.
3. Users can view archived exchange rates.
4. Users can perform buy/sell transactions.
5. Users can track transaction history.
6. The system integrates with an external API for exchange rates.

#### Non-Functional Requirements:

1. The system should ensure secure authentication and transactions.
2. The app should be responsive and user-friendly.
3. Transactions should be processed in under 2 seconds.
4. The system should be scalable to handle multiple users simultaneously.

### System Architecture

1. Use Case Diagram: [Stored in the `/docs` folder]
2. Class Diagram: [Stored in the `/docs` folder]
3. Database Schema: [Stored in the `/docs` folder]

## Installation & Setup

### Prerequisites

- Flutter SDK
- Node.js & npm
- MongoDB Database

### Backend Setup (Web Service)

```bash
# Clone the repository
git clone https://github.com/your-repo/currency-exchange.git
cd currency-exchange/backend

# Install dependencies
npm install

# Start the server
node server.js
```

### Frontend Setup (Mobile App)

```bash
cd ../mobile
flutter pub get
flutter run
```

## Testing

To run unit tests for core functionalities:

```bash
flutter test
```

## Project Management & SCRUM

The project follows an Agile SCRUM methodology and is managed using JIRA.

### Sprints Breakdown

#### Sprint 1: Core Functionality

- Set up Flutter project structure
- Implement authentication
- Fetch and display exchange rates

#### Sprint 2: Features & UI/UX Enhancements

- Implement transaction history
- Improve UI & add animations
- Add dark mode support

#### Sprint 3: Testing & Deployment

- Write unit tests
- Fix bugs
- Deploy to Firebase & Play Store

## Contributors

- Florence Matambudzo (Solo Developer)
- Student ID: [Your Student ID]

## Documentation

All system documentation (diagrams, schemas, API references) is stored in the `/docs` folder.

## License

This project is open-source and available under the MIT License.
