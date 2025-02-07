const mongoose = require('mongoose');

module.exports = {
    connectDB: async () => {
        try {
            await mongoose.connect('mongodb://localhost:27017/currency_exchange', {
                useNewUrlParser: true,
                useUnifiedTopology: true,
            });
            console.log('Connected to MongoDB');
        } catch (error) {
            console.error('Error connecting to MongoDB:', error);
            process.exit(1);
        }
    },
};
