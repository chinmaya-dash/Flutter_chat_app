import express, { Request, Response } from 'express';
import { json } from 'body-parser';
import http from 'http';
import { Server } from 'socket.io';
import authRoutes from './routes/authRoutes';
import conversationsRoutes from './routes/conversationsRoutes';
import messagesRoutes from './routes/messagesRoutes';
import contactsRoutes from './routes/contactsRoutes';
// import profileRoutes from './routes/profileRoutes';
import { saveMessage, updateMessageStatus } from './controllers/messagesController';
import dotenv from 'dotenv';
import './cron/cronJob';

dotenv.config();
// import { getUserDetails, updateProfile } from './controllers/profileController';
import chatRoutes from './routes/chatRoutes';

// import firebase
// import admin from "firebase-admin";
// import serviceAccount from "./firebaseConfig.json";

// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     storageBucket: "rtchatshareapp.appspot.com", // Replace with your Firebase bucket name
// });
// const bucket = admin.storage().bucket();
// export { bucket };

const app = express();
const server = http.createServer(app);
app.use(json());

const io = new Server(server, {
    cors: {
        origin: '*'
    }
});

// Routes
app.use('/auth', authRoutes);
app.use('/conversations', conversationsRoutes);
app.use('/messages', messagesRoutes);
app.use('/contacts', contactsRoutes);
// app.use('/profile', profileRoutes)
app.use('/api', chatRoutes);

// WebSocket connection
io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    // ✅ User joins a conversation
    socket.on('joinConversation', (conversationId) => {
        socket.join(conversationId);
        console.log(`User joined conversation: ${conversationId}`);
    });

    // ✅ Sending a new message
    socket.on('sendMessage', async (message) => {
        const { conversationId, senderId, content } = message;

        try {
            const savedMessage = await saveMessage(conversationId, senderId, content, 'sent'); // ✅ Status: 'sent'
            console.log("sendMessage:", savedMessage);
            
            // ✅ Notify both users about the new message
            io.to(conversationId).emit('newMessage', savedMessage);

            // ✅ Update last message in the conversation
            io.emit('conversationUpdated', {
                conversationId,
                lastMessage: savedMessage.content,
                lastMessageTime: savedMessage.created_at,
            });

        } catch (err) {
            console.error('Failed to save message:', err);
        }
    });

    // ✅ Handling message status updates (sent, delivered, read)
    socket.on('updateMessageStatus', async ({ messageId, status, conversationId }: { messageId: string, status: string, conversationId: string }) => {
        try {
            // ✅ Update status in database
            await updateMessageStatus(messageId, status);  

            // ✅ Emit status update only to users in the same conversation
            io.to(conversationId).emit('updateMessageStatus', { messageId, status });

            console.log(`Message ${messageId} updated to ${status}`);
        } catch (err) {
            console.error(`Failed to update message status: ${err}`);
        }
    });

    // ✅ Handling user disconnect
    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
    });

}); // ✅ Correctly closing io.on('connection', (socket) => { ... });

// Start server
const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
