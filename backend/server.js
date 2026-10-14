const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const authRoutes = require('./routes/authRoutes');
const postRoutes = require('./routes/postRoutes');
const likeRoutes = require('./routes/likeRoutes');
const commentRoutes = require('./routes/commentRoutes');

const app = express();


// Middleware
app.use(cors());
app.use(express.json());


// Routes
app.use('/api/auth', authRoutes);

app.use('/api/posts', postRoutes);

app.use('/api/likes', likeRoutes);

app.use('/api/comments', commentRoutes);


// Home
app.get('/', (req, res) => {

    res.json({
        message: 'Social Media API is running'
    });

});


// Server
const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {

    console.log(`Server running on http://172.30.30.182:${PORT}`);

});





















// const express = require('express');
// const cors = require('cors');
// const dotenv = require('dotenv');

// dotenv.config();

// const authRoutes = require('./routes/authRoutes');
// const postRoutes = require('./routes/postRoutes');
// const likeRoutes = require('./routes/likeRoutes');
// const commentRoutes = require('./routes/commentRoutes');

// const app = express();


// // Middleware
// app.use(cors());
// app.use(express.json());


// // Routes
// app.use('/api/auth', authRoutes);

// app.use('/api/posts', postRoutes);

// app.use('/api/likes', likeRoutes);

// app.use('/api/comments', commentRoutes);


// // Home
// app.get('/', (req, res) => {

//     res.json({
//         message: 'Social Media API is running'
//     });

// });


// // Server
// const PORT = process.env.PORT || 5000;

// app.listen(PORT, () => {

//     console.log(`Server running on http://localhost:${PORT}`);

// });