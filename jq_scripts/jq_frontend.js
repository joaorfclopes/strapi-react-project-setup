const jq = require('node-jq');
const fs = require('fs');

const filter = `.scripts.prod="npm run build && serve -s build"`;
const jsonPath = `${process.cwd()}/package.json`;

jq.run(filter, jsonPath).then((result) => fs.writeFile(jsonPath, result, function (err) {
    if (err) {
        return console.log(err);
    }
    console.log("\nUpdated package.json!\n");
}));
