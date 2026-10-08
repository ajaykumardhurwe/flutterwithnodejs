const db = require('../config/db');


// CREATE POST
async function createPost(req, res) {

    try {

        const { content } = req.body;

        if (!content) {
            return res.status(400).json({
                message: 'Post content is required'
            });
        }

        const userId = req.user.userId;

        const [result] = await db.query(
            `INSERT INTO posts (user_id, content)
             VALUES (?, ?)`,
            [userId, content]
        );

        res.status(201).json({
            message: 'Post created successfully',
            postId: result.insertId
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// GET ALL POSTS
async function getAllPosts(req, res) {

    try {

        const [posts] = await db.query(`
            SELECT
                p.id,
                p.content,
                p.created_at,
                u.id AS user_id,
                u.name AS user_name,

                COUNT(DISTINCT l.id) AS like_count,
                COUNT(DISTINCT c.id) AS comment_count

            FROM posts p

            INNER JOIN users u
                ON p.user_id = u.id

            LEFT JOIN likes l
                ON p.id = l.post_id

            LEFT JOIN comments c
                ON p.id = c.post_id

            GROUP BY
                p.id,
                p.content,
                p.created_at,
                u.id,
                u.name

            ORDER BY p.id DESC
        `);

        res.json(posts);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// GET SINGLE POST
async function getPostById(req, res) {

    try {

        const { id } = req.params;

        const [posts] = await db.query(`
            SELECT
                p.id,
                p.content,
                p.created_at,
                u.id AS user_id,
                u.name AS user_name,
                COUNT(DISTINCT l.id) AS like_count,
                COUNT(DISTINCT c.id) AS comment_count

            FROM posts p

            INNER JOIN users u
                ON p.user_id = u.id

            LEFT JOIN likes l
                ON p.id = l.post_id

            LEFT JOIN comments c
                ON p.id = c.post_id

            WHERE p.id = ?

            GROUP BY
                p.id,
                p.content,
                p.created_at,
                u.id,
                u.name
        `, [id]);

        if (posts.length === 0) {
            return res.status(404).json({
                message: 'Post not found'
            });
        }

        res.json(posts[0]);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// UPDATE POST
async function updatePost(req, res) {

    try {

        const { id } = req.params;
        const { content } = req.body;

        const userId = req.user.userId;

        const [result] = await db.query(
            `UPDATE posts
             SET content = ?
             WHERE id = ?
             AND user_id = ?`,
            [content, id, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                message: 'Post not found or you are not the owner'
            });
        }

        res.json({
            message: 'Post updated successfully'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


// DELETE POST
async function deletePost(req, res) {

    try {

        const { id } = req.params;
        const userId = req.user.userId;

        const [result] = await db.query(
            `DELETE FROM posts
             WHERE id = ?
             AND user_id = ?`,
            [id, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                message: 'Post not found or you are not the owner'
            });
        }

        res.json({
            message: 'Post deleted successfully'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Server error'
        });
    }
}


module.exports = {
    createPost,
    getAllPosts,
    getPostById,
    updatePost,
    deletePost
};