const { default: mongoose } = require('mongoose');
const User = require('../models/User');
const bcrypt = require('bcrypt');

// Create a new user
exports.createUser = async (req, res) => {
    console.log("Hi", req);

    const { user } = req.body;
    const { name, email, password } = user;
    console.log('Received request to create user:', name, email, password);
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ name, email, password: hashedPassword });
        console.log('New user:', newUser);
        await newUser.save();
        console.log('User saved successfully');
        res.status(201).json({ message: 'User created successfully', userId: newUser.id });
        console.log('Response sent');
    } catch (error) {
        res.status(500).json({ error: 'Error creating user' });
    }
};

// Get user by email
exports.getUserByEmail = async (req, res) => {
    console.log('Received request to get user by email:', req.params.email);
    const { email } = req.params;
    try {
        const user = await User.findOne({ email });
        if (user) {
            res.status(200).json(user);
        } else {
            console.log('User not found:', email);
            res.status(200).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ error: 'Error fetching user by email' });
    }
};

// Get user by ID
exports.getUserById = async (req, res) => {
    console.log('Received request to get user by ID:', req.params.id);

    const { id } = req.params;

    // Validate ObjectID format
    if (!mongoose.Types.ObjectId.isValid(id)) {
        console.error(`Invalid User ID:${id}`);
        return res.status(400).json({ message: 'Invalid User ID format' });
    }
    console.error(`Invalid User ID:${id}`);

    try {
        const user = await User.findOne({ id: id });
        console.log('Fetched user:', user);

        if (user) {
            console.log('User found:', user);
            res.status(200).json(user);
        } else {
            console.log('User not found:', id);
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error('Error fetching user by ID:', error);
        res.status(500).json({ error: 'Error fetching user by ID' });
    }
};
