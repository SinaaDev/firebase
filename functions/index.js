/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const functions = require('firebase-functions')
const logger = require("firebase-functions/logger");
const admin require('firebase-admin');
admin.initializeApp();

exports.onWriteLikes = functions.firestore
.documents('posts/{postId}/likes/{likesId}')
.onWrite(async (change,context)=>{
    const postId = context.params.postId;

    const postRef = admin
    .firestore()
    .collection('posts')
    .doc(postId);

    if(change.after.exist){
        return postRef.update({'likes':admin.firestore.FieldValue.increament(1)});
    }else if(!change.after.exist){
        return postRef.update({'likes':admin.firestore.FieldValue.increament(-1)});
    }else{
        return null;
    }
})