const db = require('../config/db');


// CREATE COMMENT
async function createComment(req, res) {

    try {

        const userId = req.user.userId;
        const postId = req.params.postId;
        const { comment } = req.body;

        if (!comment) {
            return res.status(400).json({
                message: 'Comment is required'
            });
        }

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

        const [result] = await db.query(
            `INSERT INTO comments
             (user_id, post_id, comment)
             VALUES (?, ?, ?)`,
            [userId, postId, comment]
        );

        res.status(201).json({
            message: 'Comment added successfully',
            commentId: result.insertId
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// GET COMMENTS
async function getComments(req, res) {

    try {

        const postId = req.params.postId;

        const [comments] = await db.query(`
            SELECT
                c.id,
                c.comment,
                c.created_at,
                u.id AS user_id,
                u.name AS user_name

            FROM comments c

            INNER JOIN users u
                ON c.user_id = u.id

            WHERE c.post_id = ?

            ORDER BY c.id DESC
        `, [postId]);

        res.json(comments);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// DELETE COMMENT
async function deleteComment(req, res) {

    try {

        const userId = req.user.userId;
        const commentId = req.params.id;

        const [result] = await db.query(
            `DELETE FROM comments
             WHERE id = ?
             AND user_id = ?`,
            [commentId, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                message: 'Comment not found or you are not the owner'
            });
        }

        res.json({
            message: 'Comment deleted successfully'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


module.exports = {
    createComment,
    getComments,
    deleteComment
};