const express = require('express');

const authenticate = require('../middleware/authMiddleware');

const {
    createPost,
    getAllPosts,
    getPostById,
    updatePost,
    deletePost
} = require('../controllers/postController');

const router = express.Router();

router.get('/', getAllPosts);

router.get('/:id', getPostById);

router.post('/', authenticate, createPost);

router.put('/:id', authenticate, updatePost);

router.delete('/:id', authenticate, deletePost);

module.exports = router;