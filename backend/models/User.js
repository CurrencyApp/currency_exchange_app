const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        default: () => new mongoose.Types.ObjectId().toString(), // Automatically generate an `id` if not provided
    },
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true, // Enforce uniqueness for the email field
    },
    password: {
        type: String,
        required: true,
    },
});

// Ensure the model is not compiled multiple times
const User = mongoose.models.User || mongoose.model('User', userSchema);

module.exports = User;
