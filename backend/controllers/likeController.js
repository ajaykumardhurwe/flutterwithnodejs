const db = require('../config/db');


// LIKE POST
async function likePost(req, res) {

    try {

        const userId = req.user.userId;
        const postId = req.params.postId;

        // Check post
        const [post] = await db.query(
            'SELECT id FROM posts WHERE id = ?',
            [postId]
        );

        if (post.length === 0) {
            return res.status(404).json({
                message: 'Post not found'
            });
        }

        // Check existing like
        const [existingLike] = await db.query(
            `SELECT id
             FROM likes
             WHERE user_id = ?
             AND post_id = ?`,
            [userId, postId]
        );

        if (existingLike.length > 0) {
            return res.status(409).json({
                message: 'You already liked this post'
            });
        }

        await db.query(
            `INSERT INTO likes (user_id, post_id)
             VALUES (?, ?)`,
            [userId, postId]
        );

        res.status(201).json({
            message: 'Post liked successfully'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// UNLIKE POST
async function unlikePost(req, res) {

    try {

        const userId = req.user.userId;
        const postId = req.params.postId;

        const [result] = await db.query(
            `DELETE FROM likes
             WHERE user_id = ?
             AND post_id = ?`,
            [userId, postId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                message: 'Like not found'
            });
        }

        res.json({
            message: 'Post unliked successfully'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


module.exports = {
    likePost,
    unlikePost
};