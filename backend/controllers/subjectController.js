const subjectModel = require('../models/subjectModel');

async function getAllSubjects(req, res) {
    try {
        const data = await subjectModel.getAllSubjects();
        res.json(data);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: 'Error fetching subjects',
            error: error.message
        });
    }
}

async function getSubjectById(req, res) {
    try {
        const data = await subjectModel.getSubjectById(req.params.id);

        if (!data) {
            return res.status(404).json({
                message: 'Subject not found'
            });
        }

        res.json(data);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: 'Error fetching subject',
            error: error.message
        });
    }
}

async function createSubject(req, res) {
    try {
        const data = await subjectModel.createSubject(req.body);

        res.status(201).json(data);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: 'Error creating subject',
            error: error.message
        });
    }
}

async function updateSubject(req, res) {
    try {
        const data = await subjectModel.updateSubject(
            req.params.id,
            req.body
        );

        res.json(data);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: 'Error updating subject',
            error: error.message
        });
    }
}

async function deleteSubject(req, res) {
    try {
        await subjectModel.deleteSubject(req.params.id);

        res.json({
            message: 'Subject deleted successfully'
        });
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: 'Error deleting subject',
            error: error.message
        });
    }
}

module.exports = {
    getAllSubjects,
    getSubjectById,
    createSubject,
    updateSubject,
    deleteSubject
};