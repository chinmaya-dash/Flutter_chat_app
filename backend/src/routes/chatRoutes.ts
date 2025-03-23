import express from 'express';
import pool from '../models/db';
import { generateDailyQuestion } from '../services/openaiService';
import { AI_BOT_ID } from '../config';

const router = express.Router();

router.post('/conversations/:conversationId/ai-message', async (req, res) => {
    try {
        console.log("AI Bot message request received");

        const { conversationId } = req.params;
        const question = await generateDailyQuestion();

        // Insert the AI-generated question into the conversation
        await pool.query(
            `
            INSERT INTO messages (conversation_id, sender_id, content)
            VALUES ($1, $2, $3)
            `,
            [conversationId, AI_BOT_ID, question]
        );

        console.log(`AI message sent for conversation ${conversationId}`);
        res.json({ message: 'AI-generated question sent successfully', content: question });
    } catch (error) {
        console.error('Error sending AI message:', error);
        res.status(500).json({ error: 'Failed to send AI message' });
    }
});

export default router;
