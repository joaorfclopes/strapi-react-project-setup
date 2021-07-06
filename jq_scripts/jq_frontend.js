const jq = require('node-jq');
const fs = require('fs');

const filter = `.scripts={
    "dev": "react-scripts start",
    "start": "node app.js",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "prod": "npm run build && http-server build -a localhost -p 3000 -o"
}`;
const jsonPath = `${process.cwd()}/package.json`;

jq.run(filter, jsonPath).then((result) => fs.writeFile(jsonPath, result, function (err) {
    if (err) {
        return console.log(err);
    }
    console.log("\nUpdated package.json!\n");
}));
