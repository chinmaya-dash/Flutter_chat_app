import express, { Request, Response } from 'express';
import {json} from 'body-parser';
import http from 'http';
import {Server} from 'socket.io';
import authRoutes from './routes/authRoutes';
import conversationsRoutes from './routes/conversationsRoutes';
import messagesRoutes from './routes/messagesRoutes';
import contactsRoutes from './routes/contactsRoutes';
// import profileRoutes from './routes/profileRoutes';
import { error } from 'console';
import { saveMessage } from './controllers/messagesController';
import dotenv from 'dotenv';
import './cron/cronJob';
dotenv.config();
// import { getUserDetails,updateProfile } from './controllers/profileController';

import chatRoutes from './routes/chatRoutes';

// importfirebase
// import admin from "firebase-admin";
// import serviceAccount from "./firebaseConfig.json";


// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     storageBucket: "rtchatshareapp.appspot.com", // Replace with your Firebase bucket name
//   });
  
//   const bucket = admin.storage().bucket();
//   export { bucket };

const app = express();
const server = http.createServer(app);
app.use(json());
const io = new Server(server, {
    cors:{
        origin: '*'
    }
})

app.use('/auth', authRoutes);
app.use('/conversations', conversationsRoutes);
app.use('/messages', messagesRoutes);
app.use('/contacts', contactsRoutes);
// app.use('/profile',profileRoutes)

app.use('/api', chatRoutes); 

io.on('connection', (socket)=> {
    console.log('A user connected:', socket.id);

    socket.on('joinConversation', (conversationId)=>{
        socket.join(conversationId);
        console.log('User joined conversation : '+conversationId);
    })

    socket.on('sendMessage', async (message)=> {
        const {conversationId, senderId, content} = message;

        try{
            const savedMessage = await saveMessage(conversationId, senderId, content);
            console.log("sendMessage : ");
            console.log(savedMessage);
            io.to(conversationId).emit('newMessage', savedMessage);

            io.emit('conversationUpdated', {
                conversationId,
                lastMessage: savedMessage.content,
                lastMessageTime: savedMessage.created_at,
            });
        } catch(err) {
            console.error('Failed to save message:', error);
        }
    });

    socket.on('disconnect', ()=>{
        console.log('User disconnected:', socket.id);
    })
    
})

const PORT = process.env.PORT || 4000;
server.listen(PORT, ()=>{
    console.log(`Server is running on port ${PORT}`);
})