const jq = require('node-jq');
const fs = require('fs');

const filter = `.scripts={
    "update-backend": "cd backend && npm install",
    "dev-backend": "cd backend && npm run develop --watch-admin",
    "prod-backend": "cd backend && npm run start",
    "build-backend": "cd backend && npm run build",
    "commit-backend": "cd backend && git add . && git commit --allow-empty -m \'backend deploy\' && git push origin master",
    "push-backend": "git subtree push --prefix backend heroku-backend master",
    "deploy-backend": "npm run build-backend && npm run commit-backend && npm run push-backend",
    "update-frontend": "cd frontend && npm install",
    "dev-frontend": "cd frontend && npm run start",
    "prod-frontend": "cd frontend && npm run prod",
    "build-frontend": "cd frontend && npm run build",
    "commit-frontend": "cd frontend && git add . && git commit --allow-empty -m \'frontend deploy\' && git push origin master",
    "push-frontend": "git subtree push --prefix frontend heroku-frontend master",
    "deploy-frontend": "npm run build-frontend && npm run commit-frontend && npm run push-frontend",
    "add-origin": "git remote add origin ${process.argv[2]}",
    "commit-origin": "git add . && git commit -m \'Project created with Strapi & React Setup\' && git push origin master",
    "update": "npm run install && npm run update-backend && npm run update-frontend",
    "dev": "concurrently \'npm run dev-backend\' \'npm run dev-frontend\'",
    "prod": "concurrently \'npm run prod-backend\' \'npm run prod-frontend\'",
    "build": "npm run build-backend && npm run build-frontend",
    "commit-full-deploy": "git add . && git commit --allow-empty -m \'full deploy\' && git push origin master",
    "full-deploy": "npm run commit-full-deploy && npm run deploy-backend && npm run deploy-frontend"
}`;
const jsonPath = `${process.cwd()}/package.json`;

jq.run(filter, jsonPath).then((result) => fs.writeFile(jsonPath, result, function (err) {
    if (err) {
        return console.log(err);
    }
    console.log("\nUpdated package.json!\n");
}));
