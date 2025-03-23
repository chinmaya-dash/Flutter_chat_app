import { Router } from 'express';
import { verifyToken } from '../middlewares/authMiddleware';
import { 
  checkOrCreateConversation, 
  fetchAllConversationsByUserId, 
  getDailyQuestion 
} from '../controllers/conversationsController';

import { sendAIBotMessage } from '../controllers/aiBotController'; // Import AI function

const router = Router();

router.get('/', verifyToken, fetchAllConversationsByUserId);
router.post('/check-or-create', verifyToken, checkOrCreateConversation);
router.get('/:id/daily-question', verifyToken, getDailyQuestion);
router.post('/:id/ai-message', verifyToken, sendAIBotMessage); // ✅ Add this line

export default router;
