const express = require('express');
const bcrypt = require('bcrypt');
const cors = require('cors');
const bodyParser = require('body-parser');
const userController = require('../controllers/userController'); // Ensure userController is correctly implemented
const User = require('../models/User');
const { default: mongoose } = require('mongoose');
const UserBalance = require('../models/UserBalance');
const Transaction = require('../models/Transaction');

const router = express.Router();

// Enable CORS
router.use(cors());

// Middleware to parse JSON bodies
router.use(express.json());
router.use(bodyParser.json());
router.use(bodyParser.urlencoded({ extended: true }));

// Simple route to test
router.get('/', (req, res) => {
    res.json({ message: 'Hello from the User API' });
});

// Login user
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: 'User does not exist' });
        }

        // Compare the hashed password
        const isMatch = await bcrypt.compare(password, user.password);

        if (isMatch) {
            res.status(200).json({ message: 'Login successful', userId: user.id });
        } else {
            res.status(401).json({ message: 'Invalid password' });
        }
    } catch (error) {
        console.error('Error logging in user:', error);
        res.status(500).json({ error: 'Error logging in user' });
    }
});

// Register a new user
router.post('/register', async (req, res) => {
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
});

// Get user by email
router.get('/email/:email', async (req, res) => {
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
});

// Get user balances
router.get('/balances/:userId', async (req, res) => {
    const userId = req.params.userId;

    try {
        // Fetch user balance from the database
        let userBalance = await UserBalance.findOne({ userId: userId });
        console.log('User Balance:', userId);
        let boolean = false;

        if (!userBalance) {
            // If user not found, return a balance of zero

            for (let i = 0; i < 2; i++) {
                const altId = await User.findOne({ _id: userId });
                userBalance = await UserBalance.findOne({ userId: altId.id });
                if (!userBalance && i === 1) {
                    // If user not found, return a balance of zero
                    return res.status(200).json({ userId, balance: 0, currency: 'PLN' });
                }
                if (userBalance && i === 0) {
                    boolean = true;
                    break;
                }

            }
        }

        // If user is found, return their balance
        console.log('User Balance:', userBalance);
        res.status(200).json({
            userId: userBalance.userId,
            balance: userBalance.balance,
            currency: userBalance.currency,
        });
    } catch (error) {
        console.error('Error fetching user balances:', error);
        res.status(500).json({ error: 'Error fetching user balances' });
    }
});

// Get user by ID
router.get('/id/:id', async (req, res) => {
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
});

// router.get('/user-details', async (req, res) => {
//     try {
//         // Assume userId is provided via query params or headers
//         const userId = req.query.userId || req.headers['user-id'];

//         if (!userId) {
//             return res.status(400).json({ error: 'User ID is required' });
//         }

//         // Fetch user balance from the database
//         const userBalance = await UserBalance.findOne({ userId });

//         if (!userBalance) {
//             // If no record is found, return a default response
//             return res.status(200).json({ userId, balance: 0, currency: 'PLN' });
//         }

//         // If user record exists, return the data
//         res.status(200).json({
//             userId: userBalance.userId,
//             balance: userBalance.balance,
//             currency: userBalance.currency,
//         });
//     } catch (error) {
//         console.error('Error fetching user details:', error);
//         res.status(500).json({ error: 'Error fetching user details' });
//     }
// });

router.get('/user-details', async (req, res) => {
    try {
        // Assume userId is provided via query params or headers
        console.log('Received request to fetch user details');
        const userId = req.query.userId || req.headers['user-id'];

        if (!userId) {
            console.log('User ID is required');
            return res.status(400).json({ error: 'User ID is required' });
        }

        // Fetch user balance from the database
        const userBalance = await UserBalance.findOne({ userId });

        if (!userBalance) {
            // If no record is found, return a default response
            console.log('No user record found');
            return res.status(200).json({ userId, balance: 0, currency: 'PLN' });
        }

        // If user record exists, return the data
        console.log('User record found');
        res.status(200).json({
            userId: userBalance.userId,
            balance: userBalance.balance,
            currency: userBalance.currency,
        });
    } catch (error) {
        console.log('Error fetching user details:', error);
        console.error('Error fetching user details:', error);
        res.status(500).json({ error: 'Error fetching user details' });
    }
});

// Fund account route
router.post('/fund', async (req, res) => {
    try {
        const { amount, currency } = req.body;

        // Validate the input
        if (!amount || amount <= 0 || !currency) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid amount or currency.',
            });
        }

        // Retrieve the userId from the request headers (or body, depending on your implementation)
        const userId = req.headers['user-id']; // Assuming userId is passed in headers

        if (!userId) {
            return res.status(400).json({ status: 'error', message: 'User ID is required.' });
        }

        // Try to find the user's balance
        let userBalance = await UserBalance.findOne({ userId });

        // If the user does not exist, create a new user record with the initial balance
        if (!userBalance) {
            userBalance = new UserBalance({
                userId,
                balance: amount, // Set the initial balance with the entered amount
                currency: currency, // Set the currency
            });

            await userBalance.save();
            return res.status(201).json({
                status: 'success',
                message: `Account created and funded with ${amount} ${currency}`,
                newBalance: userBalance.balance,
                currency: userBalance.currency,
            });
        }

        // If user balance exists, update the balance
        userBalance.balance += amount;

        // Optionally, update the currency if needed
        userBalance.currency = currency;

        // Save the updated user balance
        await userBalance.save();

        // Respond with success
        res.status(200).json({
            status: 'success',
            message: `Account funded with ${amount} ${currency}`,
            newBalance: userBalance.balance,
            currency: userBalance.currency,
        });
    } catch (error) {
        console.error('Error funding account:', error);
        res.status(500).json({ status: 'error', message: 'Error during funding process' });
    }
});

const fetchExchangeRate = async (currency) => {
    const apiUrl = `https://api.nbp.pl/api/exchangerates/rates/A/${currency}/?format=json`;
    try {
        const response = await fetch(apiUrl);
        const data = await response.json();
        return data.rates[0].mid; // Extract the exchange rate
    } catch (error) {
        throw new Error('Failed to fetch exchange rate');
    }
};

async function updateUserBalance(userId, currency, amount, type) {
    // Fetch the user's PLN balance
    const plnBalance = await UserBalance.findOne({ userId, currency: 'PLN' });

    if (!plnBalance) {
        throw new Error('PLN balance not found');
    }

    // Get the exchange rate for the currency relative to PLN
    const exchangeRate = await fetchExchangeRate(currency);

    if (type === 'buy') {
        const plnEquivalent = amount * exchangeRate; // Convert amount to PLN
        if (plnBalance.balance < plnEquivalent) {
            throw new Error('Insufficient PLN balance');
        }

        // Deduct from PLN balance
        plnBalance.balance -= plnEquivalent;

        // Check if user already has the foreign currency balance
        let userBalance = await UserBalance.findOne({ userId, currency });
        if (!userBalance) {
            // Create a new balance for the foreign currency
            userBalance = new UserBalance({
                userId,
                currency,
                balance: 0,
            });
        }

        // Add the foreign currency to the user's balance
        userBalance.balance += amount;

        // Save balances
        await userBalance.save();
        await plnBalance.save();
    } else if (type === 'sell') {
        // Check if user has enough of the foreign currency to sell
        let userBalance = await UserBalance.findOne({ userId, currency });
        if (!userBalance || userBalance.balance < amount) {
            throw new Error('Insufficient foreign currency balance');
        }

        const plnEquivalent = amount * exchangeRate; // Convert amount to PLN

        // Deduct from the foreign currency balance
        userBalance.balance -= amount;

        // Add to PLN balance
        plnBalance.balance += plnEquivalent;

        // Save balances
        await userBalance.save();
        await plnBalance.save();
    } else {
        throw new Error('Invalid transaction type');
    }
}


// Route for buying currency
router.post('/transactions/buy', async (req, res) => {
    console.log('Received buy request:', req.body);
    const { userId, currency, amount } = req.body;

    if (!userId || !currency || !amount || amount <= 0) {
        return res.status(400).json({ error: 'Invalid input' });
    }

    try {
        // Create a new transaction
        const transaction = new Transaction({
            userId,
            currency,
            amount,
            type: 'buy',
        });

        await transaction.save();

        // Update the user's balance
        await updateUserBalance(userId, currency, amount, 'buy');

        res.status(200).json({ message: 'Currency bought successfully', transaction });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Route for selling currency
router.post('/transactions/sell', async (req, res) => {
    const { userId, currency, amount } = req.body;

    if (!userId || !currency || !amount || amount <= 0) {
        return res.status(400).json({ error: 'Invalid input' });
    }

    try {
        // Create a new transaction
        const transaction = new Transaction({
            userId,
            currency,
            amount,
            type: 'sell',
        });

        await transaction.save();

        // Update the user's balance
        await updateUserBalance(userId, currency, amount, 'sell');

        res.status(200).json({ message: 'Currency sold successfully', transaction });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
