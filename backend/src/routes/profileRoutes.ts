import express from "express";
import { getUserDetails, updateProfile, deleteAccount } from "../controllers/profileController";
import { verifyToken } from "../middlewares/authMiddleware";
import pool from "../models/db"; // Import database connection

const router = express.Router();

const randomImages = [
    "https://img.freepik.com/free-photo/cute-cat-studio_23-2150932375.jpg?semt=ais_hybrid",
    "https://img.freepik.com/premium-photo/cute-cate-vector-design_780593-3.jpg?semt=ais_hybrid",
    "https://img.freepik.com/free-photo/christmas-pet-background-illustration_23-2151847693.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxSmyTnqOsoHay-NiDT-Zi4iorzBYucTpvmw&s",
    "https://img.freepik.com/premium-vector/cute-cat-cartoon-sitting_194935-99.jpg",
    "https://img.freepik.com/premium-photo/hipster-cute-pop-art-cat-illustration-hand-drawn_739548-370.jpg"
];

// ✅ Get available avatars
router.get("/avatars", verifyToken, (req, res) => {
    res.json({ avatars: randomImages });
});

// // ✅ Update profile image
// router.put("/update-profile-image", verifyToken, async (req, res) => {
//     try {
//         const { userId, newImage } = req.body;
//         if (!randomImages.includes(newImage)) {
//             return res.status(400).json({ error: "Invalid image selection" });
//         }

//         await pool.query("UPDATE users SET profile_image = $1 WHERE id = $2", [newImage, userId]);
//         res.json({ message: "Profile image updated successfully", newImage });
//     } catch (error) {
//         console.error("Failed to update profile image:", error);
//         res.status(500).json({ error: "Failed to update profile image" });
//     }
// });

// ✅ Get logged-in user's profile
router.get("/", verifyToken, getUserDetails);

// ✅ Update user profile (Keep existing functionality)
router.put("/update", verifyToken, updateProfile);

// ✅ Delete user permanently
router.delete("/delete", verifyToken, deleteAccount);

export default router;
