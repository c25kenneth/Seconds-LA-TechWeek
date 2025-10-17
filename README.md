## Inspiration
Walking through grocery aisles, we noticed how much edible food was thrown away simply for being a little “ugly.” At the same time, communities face food insecurity. Seconds bridges this gap — using AI to identify, list, and redistribute perfectly good food.

## What it does
Seconds is a two-part platform with a mobile app and a web dashboard:

🧾 For suppliers
- Snap a photo of your food item.
- Our AI model determines edibility, approximate weight, nutritional value, and expiration date.
- Instantly list the item on the Seconds marketplace.

🛒 For buyers
- Browse discounted imperfect foods on the app.
- Find affordable and fresh food from nearby suppliers.
- Purchase directly through the platform.
- Enjoy fun facts and helpful info about their food, generated using the Gemini API.

📊 For analytics
- Suppliers can view total revenue, sales history, and real-time inventory insights through the web dashboard.

## How we built it
AI/ML:
- Trained a custom convolutional neural network (EfficientNet) to detect blemishes and spoilage in food.
- Hosted the model on a FastAPI server.
- Used Gemini and LLM APIs to estimate weight, nutritional value, and expiration date.

🧠 AI Text & Engagement:
- Integrated the Gemini API to dynamically generate fun facts, storage tips, and contextual info for each food item — making the experience both informative and engaging.

📲 Mobile App (Suppliers & Buyers)
- Built using Flutter & Dart.
- Integrated Firebase Auth for secure login and Firebase Storage for image uploads.
- Real-time listings powered by Firestore.

💻 Web App (Suppliers)
- Dashboard built with React and TypeScript.
- Displays sales analytics and inventory metrics in real time.
- Pairs with the mobile app to allow businesses to manage their inventory + listings. 

## Challenges we ran into
Coordinating the database schema was difficult especially because we were working on both the web/mobile app at the same time. We spent a lot of time training an accurate model via food image data. Additionally, we spent a good amount of time fixing CORS errors when we hosted our custom CNN via FastAPI. 

## Accomplishments that we're proud of
We are proud to have been able to build a complete platform that uses AI at multiple angles. We were able to build our own CNN as well as use Gemini for text generation and some minor image processing. 

## What we learned
We learned how to simultaneously develop for both web and mobile at the same time. It was a very rewarding experience and allows for a more complete platform for our end users. 

## What's next for Seconds - Giving Slightly Imperfect Food a Second Chance
- Integrate geolocation to show nearby deals.
- Expand AI capabilities to more food categories.
- Partner with nonprofits and food banks.
- Add automated pickup and delivery options.
- Use Gemini to power chatbot-based assistance for suppliers and consumers.
- Allow for scale with potential monetization. 
