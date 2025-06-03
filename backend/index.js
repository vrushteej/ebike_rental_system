const server = require('./server');

//const port = 3000;
const port = process.env.PORT || 3000;

server.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
