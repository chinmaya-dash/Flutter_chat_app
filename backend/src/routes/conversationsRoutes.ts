import { Router } from 'express';
import { verifyToken } from '../middlewares/authMiddleware';
import { 
  checkOrCreateConversation, 
  fetchAllConversationsByUserId, 
  getDailyQuestion, 
  markMessagesAsRead
} from '../controllers/conversationsController';

import { sendAIBotMessage } from '../controllers/aiBotController'; // Import AI function

const router = Router();

router.get('/', verifyToken, fetchAllConversationsByUserId);
router.post('/check-or-create', verifyToken, checkOrCreateConversation);
router.get('/:id/daily-question', verifyToken, getDailyQuestion);
router.post('/:id/ai-message', verifyToken, sendAIBotMessage); // ✅ Add this line

router.post("/messages/mark-as-read", markMessagesAsRead);

export default router;
