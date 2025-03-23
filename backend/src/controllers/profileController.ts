import { Request, Response } from "express";
import pool from "../models/db"; // Import database connection

// ✅ Fix: Extend Express Request type to recognize `req.user`
declare module "express-serve-static-core" {
    interface Request {
        user?: { id: string };
    }
}

// ✅ Get user profile
export const getUserDetails = async (req: Request, res: Response): Promise<void> => {
    try {
        const userId = req.user?.id; // Extract user ID from token

        if (!userId) {
            res.status(401).json({ error: "Unauthorized access" });
            return;
        }

        const result = await pool.query(
            "SELECT id, username, email, profile_image, password, created_at FROM users WHERE id = $1",
            [userId]
        );

        if (result.rows.length === 0) {
            res.status(404).json({ error: "User not found" });
            return;
        }

        res.json(result.rows[0]); // ✅ Return user data
    } catch (error) {
        console.error("❌ Error fetching user profile:", error);
        res.status(500).json({ error: "Server error" });
    }
};

// ✅ Update user profile
export const updateProfile = async (req: Request, res: Response): Promise<void> => {
    try {
        const userId = req.user?.id; // Extract user ID from token

        if (!userId) {
            res.status(401).json({ error: "Unauthorized access" });
            return;
        }

        const { username, email, profile_image } = req.body;

        // ✅ Validate input (Ensure username & email are not empty)
        if (!username || !email) {
            res.status(400).json({ error: "Username and email are required" });
            return;
        }

        const result = await pool.query(
            `UPDATE users SET username = COALESCE($1, username), 
                              email = COALESCE($2, email), 
                              profile_image = COALESCE($3, profile_image) 
             WHERE id = $4 RETURNING id, username, email, profile_image`,
            [username, email, profile_image, userId]
        );

        if (result.rows.length === 0) {
            res.status(404).json({ error: "User not found" });
            return;
        }

        res.json({ message: "Profile updated successfully", user: result.rows[0] });
    } catch (error) {
        console.error("❌ Error updating profile:", error);
        res.status(500).json({ error: "Server error" });
    }
};

// ✅ Delete user account permanently
export const deleteAccount = async (req: Request, res: Response): Promise<void> => {
    try {
        const userId = req.user?.id; // Extract user ID from token

        if (!userId) {
            res.status(401).json({ error: "Unauthorized access" });
            return;
        }

        // Delete user from the database
        const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING id", [userId]);

        if (result.rows.length === 0) {
            res.status(404).json({ error: "User not found" });
            return;
        }

        res.json({ message: "Account deleted successfully" });
    } catch (error) {
        console.error("❌ Error deleting account:", error);
        res.status(500).json({ error: "Server error" });
    }
};
