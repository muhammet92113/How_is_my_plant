how_is_my_plant
A mobile application project developed with Flutter. This project is designed to provide users with information and guidance on various topics.

Features
Modern and user-friendly interface

Chatbot feature integrated with Gemini AI

Supabase backend integration

Cross-platform support (iOS, Android, Web)

Technologies
Frontend: Flutter

Backend: Supabase

AI: Google Gemini

Edge Functions: Deno

IoT: ESP32 (Arduino)

Setup
Install Flutter SDK

Clone the project:

bash
Kopyala
Düzenle
git clone https://github.com/username/how_is_my_plant.git  
cd how_is_my_plant  
Install dependencies:

bash
Kopyala
Düzenle
flutter pub get  
Run the app:

bash
Kopyala
Düzenle
flutter run  
Project Components
Flutter Application
The main mobile app with user interface and Gemini AI chatbot integration.

Supabase Edge Functions
The project uses 5 different Supabase Edge Functions:

get_plants: Retrieves the user's plants and sensor data

create_user_profile: Creates a new user profile

chatbot_gemini: Provides plant care advice using Gemini AI

send_notification: Sends notifications via Firebase Cloud Messaging

update_fcm_token: Updates the user's FCM token

For detailed setup and configuration, see the supabase_edge_functions/README.md file.

Arduino IoT System
ESP32-based sensor system collects soil moisture and light level data for plant monitoring. For details, see the arduino/ folder.

Contributing
Fork this repository

Create a new branch (git checkout -b feature/new-feature)

Commit your changes (git commit -am 'Add new feature')

Push the branch (git push origin feature/new-feature)

Create a Pull Request

License
This project is licensed under the MIT License.
