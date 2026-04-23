const Project = require('../models/Project');
const Task = require('../models/Task');

// @desc    Get all projects (created by user OR where user is member)
// @route   GET /api/projects
const getProjects = async (req, res) => {
  try {
    const assignedTasks = await Task.find({ assignedTo: req.user._id }).distinct('project');
    const projectIdsFromTasks = assignedTasks.filter(id => id != null);

    const projects = await Project.find({
      $or: [
        { createdBy: req.user._id },
        { members: req.user._id },
        { _id: { $in: projectIdsFromTasks } },
      ],
    })
      .populate('members', 'name email avatar')
      .populate('createdBy', 'name email avatar')
      .sort({ createdAt: -1 });

    const projectsWithCounts = await Promise.all(
      projects.map(async (project) => {
        const taskCount = await Task.countDocuments({ project: project._id });
        const doneCount = await Task.countDocuments({ project: project._id, status: 'done' });
        return {
          ...project.toObject(),
          taskCount,
          doneCount,
        };
      })
    );

    res.json(projectsWithCounts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get single project with its tasks
// @route   GET /api/projects/:id
const getProject = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id)
      .populate('members', 'name email avatar')
      .populate('createdBy', 'name email avatar');

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const tasks = await Task.find({ project: project._id })
      .populate('assignedTo', 'name email avatar')
      .populate('createdBy', 'name email avatar')
      .sort({ createdAt: -1 });

    const taskCount = tasks.length;
    const doneCount = tasks.filter(t => t.status === 'done').length;

    res.json({ ...project.toObject(), tasks, taskCount, doneCount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a project
// @route   POST /api/projects
const createProject = async (req, res) => {
  try {
    const { name, description, color, members } = req.body;

    const project = await Project.create({
      name,
      description,
      color: color || '#009688',
      members: members || [req.user._id],
      createdBy: req.user._id,
    });

    const populatedProject = await Project.findById(project._id)
      .populate('members', 'name email avatar')
      .populate('createdBy', 'name email avatar');

    res.status(201).json({ ...populatedProject.toObject(), taskCount: 0, doneCount: 0 });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update a project
// @route   PUT /api/projects/:id
const updateProject = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id);

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    if (project.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the creator can update this project' });
    }

    const updatedProject = await Project.findByIdAndUpdate(req.params.id, req.body, { new: true })
      .populate('members', 'name email avatar')
      .populate('createdBy', 'name email avatar');

    const taskCount = await Task.countDocuments({ project: updatedProject._id });
    const doneCount = await Task.countDocuments({ project: updatedProject._id, status: 'done' });

    res.json({ ...updatedProject.toObject(), taskCount, doneCount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete a project
// @route   DELETE /api/projects/:id
const deleteProject = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id);

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    if (project.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the creator can delete this project' });
    }

    await Task.deleteMany({ project: project._id });
    await Project.findByIdAndDelete(req.params.id);

    res.json({ message: 'Project and its tasks removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getProjects, getProject, createProject, updateProject, deleteProject };
