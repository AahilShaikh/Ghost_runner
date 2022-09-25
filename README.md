1st place winner at WWP Hacks 2
# Inspiration
You wake up in the morning ready to finally start jogging. But by the time you finish brushing your teeth. Your motivation has left as quickly as it came to you. This is the story of thousands of people every day - just like you and me, who cannot embark on their fitness transformation because of their very human nature. They lack conviction and motivation because potential future results are way too far.

# What it does
This is where our app (iOS and Android), Ghost Trainer, comes into play. You race your own yourself and can see instant improvement every day, offline and online. Ghost trainer tracks your run at every instant, capturing performance at the minuscule level, and builds a "ghost" of yourself that emulates every part of your run: that initial slow start, that slowing down due to fatigue, and even that part where your afterburners kicked in near the finish line. This ghost constantly adapts to and mimics your increasing fitness levels, ensuring that when you race against it, you're constantly being pushed to your limits, and then breaking them.

Lack of motivation is now a thing of the past, Ghost Trainer allows you to see your metrics and your subsequent improvements at any time, fueling your motivation.

# How we built it
We utilized the language Dart, with a framework called Flutter to create the bulk of our app. Since Flutter is cross-platform, we were able to utilize one codebase to create app store-ready apps. Additionally, we used the OpenStreetMap database to create our in-app map and the GPS system of a phone to get location data. We also used Firebase Cloud Firestore to store our data in the cloud. This also allowed us to expand the offline capabilities of our app by saving data in the app cache and then uploading it to the database when internet connectivity is restored. We also utilized Firebase Authentication to manage authentication in our app.

# Challenges we ran into
Both of us did not have any experience working with latitude and longitude points. As such, we had to do a lot of research to figure out how to calculate distance, speed, store data, etc. We eventually used the Vincenty algorithm to find the distance, and the Catmull-Rom algorithm smooth out the path and remove any outlier data points.

# Accomplishments that we're proud of
We're really proud that we were able to create a production-ready, cross-platform app in less than 24 hours. We are also really happy with the way that the UI came out and well everything works together.

# What we learned
Latitude-Longitude algorithms
Displaying maps on mobile phones
How to take GPS data from the phone ## What's next for Ghost Trainer Better metrics tracking and also map-matching to improve the quality of data points taken from the phone GPS.
