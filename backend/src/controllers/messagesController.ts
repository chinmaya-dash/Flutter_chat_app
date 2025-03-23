import { Request, Response } from "express";
import pool from "../models/db";


export const fetchAllMessagesByConversationId = async (req: Request, res: Response) => {
    const { conversationId } = req.params;

    try{
        const result = await pool.query(
            `
            SELECT m.id, m.content, m.sender_id, m.conversation_id, m.created_at
            From messages m
            Where m.conversation_id = $1
            Order by m.created_at ASC;
            `,
            [conversationId]
        );

        res.json(result.rows);
    } catch(err){
        res.status(500).json({error: 'Failed to fetch messages'});
    }
}

export const saveMessage = async (conversationId: string, senderId: string, content: string, status: string) => {
    try {
        const result = await pool.query(
            `
            INSERT INTO messages (conversation_id, sender_id, content, status)
            VALUES ($1, $2, $3, $4)
            RETURNING *;
            `,
            [conversationId, senderId, content, status] // ✅ Include status parameter
        );

        return result.rows[0];
    } catch (err) {
        console.error("Error saving message:", err);
        throw new Error("Failed to save message");
    }
};

export async function updateMessageStatus(messageId: string, status: string): Promise<void> {
    try {
        await pool.query(
            `UPDATE messages SET status = $1 WHERE id = $2`,
            [status, messageId]
        );
        console.log(`Message ${messageId} status updated to ${status}`);
    } catch (error) {
        console.error("Error updating message status:", error);
        throw error;
    }
}
