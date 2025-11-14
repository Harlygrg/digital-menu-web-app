   // firebase-messaging-sw.js
   // This file is required for Firebase Cloud Messaging to work in Flutter Web apps

   // Import Firebase scripts
   importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js");
   importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging.js");

   // Initialize Firebase (replace with your Firebase config)
   firebase.initializeApp({
     apiKey: "AIzaSyBJxOGTP2Cvo4Hm_7-iWs9P24Zhxh3g0Qs",
     authDomain: "msi-restaurant.firebaseapp.com",
     projectId: "msi-restaurant",
     storageBucket: "msi-restaurant.firebasestorage.app",
     messagingSenderId: "221528008029",
     appId: "1:221528008029:web:fd696489debba24615f4b4",
   });

   // Retrieve Firebase Messaging instance
   const messaging = firebase.messaging();

   // Optional: Handle background push notifications
   messaging.onBackgroundMessage(function(payload) {
     console.log("📩 Received background message:", payload);

     const notificationTitle = payload.notification?.title || "New Notification";
     const notificationOptions = {
       body: payload.notification?.body || "",
       icon: "/icons/Icon-192.png", // path to your app icon
     };

     self.registration.showNotification(notificationTitle, notificationOptions);
   });
