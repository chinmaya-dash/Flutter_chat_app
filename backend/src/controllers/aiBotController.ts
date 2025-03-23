import { Request, Response } from 'express';
import pool from '../models/db';
import { generateDailyQuestion } from '../services/openaiService';
// import { AI_BOT_ID } from '../config';

export const sendAIBotMessage = async (req: Request, res: Response) => {
    const conversationId = req.params.id;

    try {
        const question = await generateDailyQuestion();

        await pool.query(
            `INSERT INTO messages (conversation_id, sender_id, content) VALUES ($1, $2, $3)`,
            [conversationId, process.env.AI_BOT_ID, question]
        );

        res.json({ content: question });
    } catch (error) {
        console.error('Error sending AI bot message:', error);
        res.status(500).json({ error: 'Failed to send AI bot message' });
    }
};
