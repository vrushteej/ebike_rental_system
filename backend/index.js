const app = require('./app');
const db = require('./config/db');


//const port = 3000;
const port = process.env.PORT || 3000;

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
