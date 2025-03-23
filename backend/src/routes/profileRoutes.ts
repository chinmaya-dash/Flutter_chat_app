import express from "express";
import { getUserDetails, updateProfile, deleteAccount } from "../controllers/profileController";
import { verifyToken } from "../middlewares/authMiddleware"; // Ensure correct import path

const router = express.Router();

// Get logged-in user's profile
router.get("/", verifyToken, getUserDetails);

// Update user profile (Consistent Route)
router.put("/update", verifyToken, updateProfile);

// Delete user permanently
router.delete("/delete", verifyToken, deleteAccount);

export default router;
