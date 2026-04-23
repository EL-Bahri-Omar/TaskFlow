const Task = require('../models/Task');
const Notification = require('../models/Notification');

// @desc    Get all tasks (with filters)
// @route   GET /api/tasks
const getTasks = async (req, res) => {
  try {
    const { status, project } = req.query;
    let filter = {};

    // Show tasks created by or assigned to the user
    filter.$or = [
      { createdBy: req.user._id },
      { assignedTo: req.user._id },
    ];

    if (status) filter.status = status;
    if (project) filter.project = project;

    const tasks = await Task.find(filter)
      .populate('assignedTo', 'name email avatar')
      .populate('project', 'name color')
      .populate('createdBy', 'name email avatar')
      .sort({ createdAt: -1 });

    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get task statistics for current user (assigned tasks only)
// @route   GET /api/tasks/stats
const getTaskStats = async (req, res) => {
  try {
    const userId = req.user._id;
    const assignedFilter = { assignedTo: userId };

    const total = await Task.countDocuments(assignedFilter);
    const todo = await Task.countDocuments({ ...assignedFilter, status: 'todo' });
    const inProgress = await Task.countDocuments({ ...assignedFilter, status: 'inProgress' });
    const done = await Task.countDocuments({ ...assignedFilter, status: 'done' });

    res.json({ total, todo, inProgress, done });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get single task
// @route   GET /api/tasks/:id
const getTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('assignedTo', 'name email avatar')
      .populate('project', 'name color')
      .populate('createdBy', 'name email avatar');

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.json(task);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a task
// @route   POST /api/tasks
const createTask = async (req, res) => {
  try {
    const { title, description, status, priority, dueDate, project, assignedTo } = req.body;

    const task = await Task.create({
      title,
      description,
      status,
      priority,
      dueDate,
      project: project || null,
      assignedTo: assignedTo || null,
      createdBy: req.user._id,
    });

    const populatedTask = await Task.findById(task._id)
      .populate('assignedTo', 'name email avatar')
      .populate('project', 'name color')
      .populate('createdBy', 'name email avatar');

    // Create notification if task is assigned to someone
    if (assignedTo && assignedTo.toString() !== req.user._id.toString()) {
      try {
        const notif = await Notification.create({
          recipient: assignedTo,
          message: `A task has been assigned to you: "${title}"`,
          task: task._id,
        });
        console.log('Notification created:', notif._id, 'for user:', assignedTo);
      } catch (notifErr) {
        console.error('Failed to create notification:', notifErr.message);
      }
    }

    // If the task belongs to a project, add the assignee as a member
    if (project && assignedTo) {
      try {
        const Project = require('../models/Project');
        await Project.findByIdAndUpdate(project, {
          $addToSet: { members: assignedTo },
        });
      } catch (projErr) {
        console.error('Failed to add member to project:', projErr.message);
      }
    }

    res.status(201).json(populatedTask);
  } catch (error) {
    console.error('Create task error:', error.message);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update a task
// @route   PUT /api/tasks/:id
const updateTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const isCreator = task.createdBy.toString() === req.user._id.toString();
    const isAssignee = task.assignedTo && task.assignedTo.toString() === req.user._id.toString();

    // Assignee can only update status
    if (!isCreator && isAssignee) {
      if (Object.keys(req.body).length > 1 || !req.body.status) {
        return res.status(403).json({ message: 'You can only update the status of this task' });
      }
    }

    // Not creator and not assignee = no access
    if (!isCreator && !isAssignee) {
      return res.status(403).json({ message: 'Not authorized to update this task' });
    }

    // Check if assignedTo changed
    const oldAssignedTo = task.assignedTo ? task.assignedTo.toString() : null;
    const newAssignedTo = req.body.assignedTo || null;

    // Build update object — only include fields that were explicitly sent
    const updateFields = {};
    if (req.body.title !== undefined) updateFields.title = req.body.title;
    if (req.body.description !== undefined) updateFields.description = req.body.description;
    if (req.body.status !== undefined) updateFields.status = req.body.status;
    if (req.body.priority !== undefined) updateFields.priority = req.body.priority;
    if (req.body.dueDate !== undefined) updateFields.dueDate = req.body.dueDate;
    if (req.body.project !== undefined) updateFields.project = req.body.project || null;
    if (req.body.assignedTo !== undefined) updateFields.assignedTo = req.body.assignedTo || null;

    const updatedTask = await Task.findByIdAndUpdate(
      req.params.id,
      updateFields,
      { new: true }
    )
      .populate('assignedTo', 'name email avatar')
      .populate('project', 'name color')
      .populate('createdBy', 'name email avatar');

    // Notify new assignee if assignment changed
    if (isCreator && newAssignedTo && newAssignedTo !== oldAssignedTo && newAssignedTo !== req.user._id.toString()) {
      try {
        await Notification.create({
          recipient: newAssignedTo,
          message: `A task has been assigned to you: "${updatedTask.title}"`,
          task: task._id,
        });
      } catch (notifErr) {
        console.error('Failed to create notification:', notifErr.message);
      }

      // Add new assignee to project members
      if (updatedTask.project) {
        try {
          const Project = require('../models/Project');
          await Project.findByIdAndUpdate(updatedTask.project._id || updatedTask.project, {
            $addToSet: { members: newAssignedTo },
          });
        } catch (projErr) {
          console.error('Failed to add member to project:', projErr.message);
        }
      }
    }

    res.json(updatedTask);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete a task
// @route   DELETE /api/tasks/:id
const deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    if (task.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the creator can delete this task' });
    }

    await Task.findByIdAndDelete(req.params.id);
    res.json({ message: 'Task removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getTasks, getTaskStats, getTask, createTask, updateTask, deleteTask };
