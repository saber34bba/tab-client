importScripts("https://www.gstatic.com/firebasejs/9.15.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.15.0/firebase-messaging-compat.js")

console.warn("firebase-messaging-sw.js");
firebase.initializeApp({
    apiKey: 'AIzaSyBSWfme3FulpbRxcMzQ9JOaRUJPWIn2vKo',
    appId: '1:391440289487:web:20e496a065e0c4c03e31ba',
    messagingSenderId: '391440289487',
    projectId: 'the-africanbasket-351412',
    authDomain: 'the-africanbasket-351412.firebaseapp.com',
    databaseURL: 'https://the-africanbasket-351412-default-rtdb.firebaseio.com',
    storageBucket: 'the-africanbasket-351412.appspot.com',
});

if(firebase.messaging.isSupported()){
    const messaging = firebase.messaging();

    // messaging.setBackgroundMessageHandler(function (payload) {
    //     const promiseChain = clients
    //         .matchAll({
    //             type: "window",
    //             includeUncontrolled: true
    //         })
    //         .then(windowClients => {
    //             for (let i = 0; i < windowClients.length; i++) {
    //                 const windowClient = windowClients[i];
    //                 windowClient.postMessage(payload);
    //             }
    //         })
    //         .then(() => {
    //             const title = payload.notification.title;
    //             const options = {
    //                 body: payload.notification.score
    //               };
    //               console.log(payload)
    //             return registration.showNotification(title, options);
    //         });
    //     return promiseChain;
    // });
    // self.addEventListener('notificationclick', function (event) {
    //     console.log('notification received: ', event)
    // });
    // Optional:
    messaging.onBackgroundMessage((m) => {
        console.log("onBackgroundMessage", m);
    });
    messaging.onMessage((m) => {
        console.log("onMessage", m);
    });
}

