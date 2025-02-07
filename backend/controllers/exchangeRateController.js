const ExchangeRate = require('../models/ExchangeRate');

exports.getExchangeRates = async (req, res) => {
    try {
        const rates = await ExchangeRate.find();
        res.status(200).json(rates);
    } catch (error) {
        res.status(500).json({ error: 'Error fetching exchange rates' });
    }
};

exports.addExchangeRate = async (req, res) => {
    const { currency, rate } = req.body;
    try {
        const newRate = new ExchangeRate({ currency, rate });
        await newRate.save();
        res.status(201).json({ message: 'Exchange rate added successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Error adding exchange rate' });
    }
};
