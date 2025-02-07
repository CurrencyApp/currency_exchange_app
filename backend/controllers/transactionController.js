const Transaction = require('../models/Transaction');

exports.createTransaction = async (req, res) => {
    const { userId, currency, amount, type } = req.body;
    try {
        const newTransaction = new Transaction({
            userId,
            currency,
            amount,
            type,
            date: new Date(),
        });
        await newTransaction.save();
        res.status(201).json({ message: 'Transaction created successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Error creating transaction' });
    }
};


// Calculate total balance for a user
exports.getUserBalances = async (req, res) => {
    const { userId } = req.params;

    if (!userId) {
        return res.status(400).json({ message: 'User ID is required' });
    }

    try {
        // Fetch all transactions for the user
        const transactions = await Transaction.find({ userId });

        // Calculate balance for each currency
        const balances = transactions.reduce((acc, transaction) => {
            const { currency, amount, type } = transaction;

            if (!acc[currency]) {
                acc[currency] = 0;
            }

            if (type === 'buy') {
                acc[currency] += amount;
            } else if (type === 'sell') {
                acc[currency] -= amount;
            }

            return acc;
        }, {});

        res.status(200).json({ userId, balances });
    } catch (error) {
        console.error('Error fetching user balances:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}