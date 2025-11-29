// Firebase Cloud Messaging Service Worker
// Handles background notifications when the web app is not in focus
// Works for both browser and PWA installations

// Import Firebase scripts (use compat version for service workers)
// Using version 10.7.0 - latest stable compat version
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Initialize Firebase in the service worker
// These values should match your Firebase project configuration
firebase.initializeApp({
  apiKey: "AIzaSyBJxOGTP2Cvo4Hm_7-iWs9P24Zhxh3g0Qs",
  authDomain: "msi-restaurant.firebaseapp.com",
  projectId: "msi-restaurant",
  storageBucket: "msi-restaurant.firebasestorage.app",
  messagingSenderId: "221528008029",
  appId: "1:221528008029:web:fd696489debba24615f4b4"
});

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages (app in background or minimized)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] 📨 Background message received:', payload);

  // Extract notification data
  const notificationTitle = payload.notification?.title || 'Order Update';
  const notificationBody = payload.notification?.body || 'Your order status has been updated';
  
  // Build notification options
  const notificationOptions = {
    body: notificationBody,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.orderId || 'order-notification',
    requireInteraction: false, // Allow auto-dismiss after timeout
    data: {
      ...payload.data,
      url: '/order-tracking', // Always navigate to order tracking
      clickAction: 'FLUTTER_NOTIFICATION_CLICK'
    },
    actions: [
      {
        action: 'view',
        title: 'View Orders'
      }
    ]
  };

  console.log('[firebase-messaging-sw.js] 🔔 Showing notification:', notificationTitle);
  
  // Display the notification
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks (background or terminated state)
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] 🖱️ Notification clicked:', event);
  
  // Close the notification
  event.notification.close();
  
  // Get the target URL from notification data
  const targetUrl = event.notification.data?.url || '/order-tracking';
  const fullUrl = new URL(targetUrl, self.location.origin).href;
  
  console.log('[firebase-messaging-sw.js] 🎯 Target URL:', fullUrl);
  
  // Handle different actions
  if (event.action === 'view' || !event.action) {
    // View action or default click (on notification body)
    event.waitUntil(
      clients.matchAll({ 
        type: 'window', 
        includeUncontrolled: true 
      }).then((clientList) => {
        console.log('[firebase-messaging-sw.js] 👀 Found clients:', clientList.length);
        
        // First, try to find and focus an existing window
        for (let i = 0; i < clientList.length; i++) {
          const client = clientList[i];
          
          // Check if client is from the same origin
          if (client.url.startsWith(self.location.origin)) {
            console.log('[firebase-messaging-sw.js] ✅ Focusing existing window and navigating');
            
            // Focus the window and send navigation message
            return client.focus().then(focusedClient => {
              // Send message to client to navigate
              if (focusedClient.postMessage) {
                focusedClient.postMessage({
                  type: 'NOTIFICATION_CLICK',
                  url: targetUrl,
                  data: event.notification.data
                });
              }
              return focusedClient;
            });
          }
        }
        
        // No existing window found - open new one
        console.log('[firebase-messaging-sw.js] 🆕 Opening new window');
        if (clients.openWindow) {
          return clients.openWindow(fullUrl);
        }
      }).catch(error => {
        console.error('[firebase-messaging-sw.js] ❌ Error handling notification click:', error);
      })
    );
  }
});

// Handle service worker activation
self.addEventListener('activate', (event) => {
  console.log('[firebase-messaging-sw.js] ✅ Service worker activated');
  // Claim all clients immediately
  event.waitUntil(clients.claim());
});

// Handle service worker installation
self.addEventListener('install', (event) => {
  console.log('[firebase-messaging-sw.js] 📦 Service worker installed');
  // Skip waiting to activate immediately
  self.skipWaiting();
});

// Listen for messages from the app
self.addEventListener('message', (event) => {
  console.log('[firebase-messaging-sw.js] 💬 Message from app:', event.data);
  
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

