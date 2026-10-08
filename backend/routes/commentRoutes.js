const express = require('express');

const authenticate = require('../middleware/authMiddleware');

const {
    createComment,
    getComments,
    deleteComment
} = require('../controllers/commentController');

const router = express.Router();

router.get('/post/:postId', getComments);

router.post('/post/:postId', authenticate, createComment);

router.delete('/:id', authenticate, deleteComment);

module.exports = router;