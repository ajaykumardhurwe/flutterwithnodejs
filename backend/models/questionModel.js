const db = require('../config/db');

async function getAllQuestions() {

    const [rows] = await db.query(`
        SELECT
            q.Id AS id,
            q.Question AS question,
            q.OptionA AS optionA,
            q.OptionB AS optionB,
            q.OptionC AS optionC,
            q.OptionD AS optionD,
            q.CorrectAnswer AS correctAnswer,
            q.Explanation AS explanation,
            q.SubjectId AS subjectId,
            s.Name AS subjectName,
            q.IsActive AS isActive
        FROM Questions q
        LEFT JOIN Subjects s
            ON q.SubjectId = s.Id
        ORDER BY q.Id DESC
    `);

    return rows;
}

async function getQuestionById(id) {

    const [rows] = await db.execute(
        `
        SELECT
            q.Id AS id,
            q.Question AS question,
            q.OptionA AS optionA,
            q.OptionB AS optionB,
            q.OptionC AS optionC,
            q.OptionD AS optionD,
            q.CorrectAnswer AS correctAnswer,
            q.Explanation AS explanation,
            q.SubjectId AS subjectId,
            s.Name AS subjectName,
            q.IsActive AS isActive
        FROM Questions q
        LEFT JOIN Subjects s
            ON q.SubjectId = s.Id
        WHERE q.Id = ?
        `,
        [id]
    );

    return rows[0];
}

async function getQuestionsBySubject(subjectId) {

    const [rows] = await db.execute(
        `
        SELECT
            q.Id AS id,
            q.Question AS question,
            q.OptionA AS optionA,
            q.OptionB AS optionB,
            q.OptionC AS optionC,
            q.OptionD AS optionD,
            q.CorrectAnswer AS correctAnswer,
            q.Explanation AS explanation,
            q.SubjectId AS subjectId,
            s.Name AS subjectName,
            q.IsActive AS isActive
        FROM Questions q
        LEFT JOIN Subjects s
            ON q.SubjectId = s.Id
        WHERE q.SubjectId = ?
        ORDER BY q.Id DESC
        `,
        [subjectId]
    );

    return rows;
}

async function subjectExists(subjectId) {

    const [rows] = await db.execute(
        `
        SELECT Id
        FROM Subjects
        WHERE Id = ?
        `,
        [subjectId]
    );

    return rows.length > 0;
}

async function createQuestion(data) {

    const [result] = await db.execute(
        `
        INSERT INTO Questions
        (
            Question,
            OptionA,
            OptionB,
            OptionC,
            OptionD,
            CorrectAnswer,
            Explanation,
            SubjectId,
            IsActive
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
            data.question,
            data.optionA,
            data.optionB,
            data.optionC,
            data.optionD,
            data.correctAnswer,
            data.explanation || null,
            data.subjectId,
            true
        ]
    );

    return getQuestionById(result.insertId);
}

async function updateQuestion(id, data) {

    await db.execute(
        `
        UPDATE Questions
        SET
            Question = ?,
            OptionA = ?,
            OptionB = ?,
            OptionC = ?,
            OptionD = ?,
            CorrectAnswer = ?,
            Explanation = ?,
            SubjectId = ?,
            IsActive = ?
        WHERE Id = ?
        `,
        [
            data.question,
            data.optionA,
            data.optionB,
            data.optionC,
            data.optionD,
            data.correctAnswer,
            data.explanation || null,
            data.subjectId,
            data.isActive ?? true,
            id
        ]
    );

    return getQuestionById(id);
}

async function deleteQuestion(id) {

    await db.execute(
        `DELETE FROM Questions WHERE Id = ?`,
        [id]
    );
}

module.exports = {
    getAllQuestions,
    getQuestionById,
    getQuestionsBySubject,
    subjectExists,
    createQuestion,
    updateQuestion,
    deleteQuestion
};