const mongoose = require('mongoose');

const userBalanceSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
    },
    balance: {
        type: Number,
        required: true,
    },
    currency: {
        type: String,
        required: true,
    },
});

const UserBalance = mongoose.model('UserBalance', userBalanceSchema);

module.exports = UserBalance;
