const express = require('express');

const authenticate = require('../middleware/authMiddleware');

const {
    likePost,
    unlikePost
} = require('../controllers/likeController');

const router = express.Router();

router.post('/:postId', authenticate, likePost);

router.delete('/:postId', authenticate, unlikePost);

module.exports = router;