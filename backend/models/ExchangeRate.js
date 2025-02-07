const mongoose = require('mongoose');

const exchangeRateSchema = new mongoose.Schema({
    currency: {
        type: String,
        required: true,
    },
    rate: {
        type: Number,
        required: true,
    },
});

const ExchangeRate = mongoose.model('ExchangeRate', exchangeRateSchema);

module.exports = ExchangeRate;
