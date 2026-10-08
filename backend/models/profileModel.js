const db = require('../config/db');

async function getAllProfiles() {

    const [rows] = await db.query(`
        SELECT
            Id AS id,
            Name AS name,
            Email AS email,
            Phone AS phone,
            Bio AS bio,
            IsActive AS isActive
        FROM UserProfiles
        ORDER BY Id DESC
    `);

    return rows;
}

async function getProfileById(id) {

    const [rows] = await db.execute(
        `
        SELECT
            Id AS id,
            Name AS name,
            Email AS email,
            Phone AS phone,
            Bio AS bio,
            IsActive AS isActive
        FROM UserProfiles
        WHERE Id = ?
        `,
        [id]
    );

    return rows[0];
}

async function createProfile(data) {

    const [result] = await db.execute(
        `
        INSERT INTO UserProfiles
        (
            Name,
            Email,
            Phone,
            Bio,
            IsActive
        )
        VALUES (?, ?, ?, ?, ?)
        `,
        [
            data.name,
            data.email,
            data.phone || null,
            data.bio || null,
            true
        ]
    );

    return getProfileById(result.insertId);
}

async function updateProfile(id, data) {

    await db.execute(
        `
        UPDATE UserProfiles
        SET
            Name = ?,
            Email = ?,
            Phone = ?,
            Bio = ?,
            IsActive = ?
        WHERE Id = ?
        `,
        [
            data.name,
            data.email,
            data.phone || null,
            data.bio || null,
            data.isActive ?? true,
            id
        ]
    );

    return getProfileById(id);
}

async function deleteProfile(id) {

    await db.execute(
        `DELETE FROM UserProfiles WHERE Id = ?`,
        [id]
    );
}

module.exports = {
    getAllProfiles,
    getProfileById,
    createProfile,
    updateProfile,
    deleteProfile
};