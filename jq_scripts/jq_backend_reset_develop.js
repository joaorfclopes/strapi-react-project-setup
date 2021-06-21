const jq = require('node-jq');
const fs = require('fs');

const filter = `.scripts.develop="strapi develop"`;
const jsonPath = `${process.cwd()}/package.json`;

jq.run(filter, jsonPath).then((result) => fs.writeFile(jsonPath, result, function (err) {
    if (err) {
        return console.log(err);
    }
    console.log("Backend created!");
}));
