const db = require('../config/db');

async function getAllSubjects() {

    const [rows] = await db.query(`
        SELECT
            Id AS id,
            Name AS name,
            Description AS description,
            IsActive AS isActive
        FROM Subjects
        ORDER BY Id DESC
    `);

    return rows;
}

async function getSubjectById(id) {

    const [rows] = await db.execute(
        `
        SELECT
            Id AS id,
            Name AS name,
            Description AS description,
            IsActive AS isActive
        FROM Subjects
        WHERE Id = ?
        `,
        [id]
    );

    return rows[0];
}

async function createSubject(data) {

    const [result] = await db.execute(
        `
        INSERT INTO Subjects
        (Name, Description, IsActive)
        VALUES (?, ?, ?)
        `,
        [
            data.name,
            data.description || null,
            data.isActive ?? true
        ]
    );

    return getSubjectById(result.insertId);
}

async function updateSubject(id, data) {

    await db.execute(
        `
        UPDATE Subjects
        SET
            Name = ?,
            Description = ?,
            IsActive = ?
        WHERE Id = ?
        `,
        [
            data.name,
            data.description || null,
            data.isActive ?? true,
            id
        ]
    );

    return getSubjectById(id);
}

async function deleteSubject(id) {

    await db.execute(
        `DELETE FROM Subjects WHERE Id = ?`,
        [id]
    );
}

module.exports = {
    getAllSubjects,
    getSubjectById,
    createSubject,
    updateSubject,
    deleteSubject
};