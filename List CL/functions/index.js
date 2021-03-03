const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const env = functions.config();


exports.indexUser = functions.firestore
    .document('posts/{userId}')
    .onCreate(() => {
        const db = admin.firestore();
        const docRef = db.collection('controls').doc('postCount');
        return docRef.update({
            count: admin.firestore.FieldValue.increment(1)
        });
    });


exports.unindexUser = functions.firestore
    .document('posts/{userId}')
    .onDelete(()=> {
        const db = admin.firestore();
        const docRef = db.collection('controls').doc('postCount');
        return docRef.update({
            count: admin.firestore.FieldValue.increment(-1)
        });
    })