const jq = require('node-jq');
const fs = require('fs');

const filter = `.scripts={
    "dev": "react-scripts start",
    "start": "npm run build && serve -s build",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "heroku-postbuild": "npm run build"
}`;
const jsonPath = `${process.cwd()}/package.json`;

jq.run(filter, jsonPath).then((result) => fs.writeFile(jsonPath, result, function (err) {
    if (err) {
        return console.log(err);
    }
    console.log("\nUpdated package.json!\n");
}));
