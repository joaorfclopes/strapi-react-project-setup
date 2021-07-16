#!/bin/bash

function welcome() {
    echo 'Welcome to Strapi & React project setup!'
    echo ''
    user=$(whoami)
}

function check_node() {
    lowest_version="10.16.0"
    highest_version="14.x.x"
    if-node-version "<$lowest_version" && echo "Node Version must be at least $lowest_version" && echo '' && exit 1
    if-node-version ">$highest_version" && echo "Node Version can't be higher than $highest_version" && echo '' && exit 1
}

function node_version() {
    echo 'Installing dependencies...'
    npm install --save if-node-version
    echo 'Checking node version...'
    node -v
    check_node
    echo ''
}

function error_on_read() {
    echo "Value can't be empty..."
    echo ''
    $1
}

function create_dir() {
    read -p 'Project Name: ' dir_name
    if [ -z "$dir_name" ]; then
        error_on_read create_dir
    else
        cd .. && mkdir $dir_name
        echo "Directory $dir_name created!"
        echo ''
    fi
}

function read_repository_url() {
    read -p 'Repository URL: ' repository_url
    if [ -z "$repository_url" ]; then
        error_on_read read_repository_url
    else
        git remote add origin $repository_url
        node jq_scripts/jq_general.js $repository_url
    fi
}

function project_init() {
    create_dir
    echo 'Initiating npm & git project...'
    cp -R strapi-react-project-setup/jq_scripts $dir_name
    cp -R strapi-react-project-setup/backend_config $dir_name
    cp -R strapi-react-project-setup/frontend_config $dir_name
    echo "Scripts copied to $dir_name!"
    cd $dir_name
    echo ''
    npm init -y
    echo 'Installing packages...'
    npm install node-jq concurrently --save
    echo ''
    git init
    printf '%s\n' 'node_modules' 'package-lock.json' '.DS_Store' 'jq_scripts' >>.gitignore
    echo ''
    read_repository_url
    start_heroku
}

function check_heroku() {
    if [ $? -eq 0 ]; then
        echo ''
        echo OK
        echo ''
    else
        heroku_login
    fi
}

function start_heroku() {
    command -v heroku >/dev/null 2>&1 || {
        echo >&2 "Heroku must be installed. Installing via NPM..."
        npm install -g heroku
    }
    heroku whoami
    check_heroku
}

function heroku_login() {
    echo ''
    echo 'Please login in Heroku'
    heroku login -i
    check_heroku
}

function setup_heroku_backend() {
    echo 'Setting up heroku backend...'
    echo ''
    backend_name="$dir_name-$user-backend"
    heroku create $backend_name
    heroku pipelines:create $dir_name -a $backend_name -s production
    heroku addons:create heroku-postgresql:hobby-dev
    heroku config
    heroku config:set NODE_ENV=production
    heroku config:set MY_HEROKU_URL=$(heroku info -s | grep web_url | cut -d= -f2)
    git remote remove heroku
    heroku git:remote -a $backend_name -r heroku-backend
    echo ''
    echo 'Heroku backend setup done!'
    echo ''
}

function setup_backend_deploy() {
    echo 'Setting up backend for deploy...'
    echo ''
    npm install pg-connection-string pg --save
    mkdir -p ./config/env/production
    echo ''
    echo 'Copying config files to backend...'
    pwd
    cp ../backend_config/database.js ./config/env/production
    cp ../backend_config/server.js ./config/env/production
    echo ''
    echo 'Config files copied!'
    echo ''
    echo 'Backend ready for deploy!'
    echo ''
}

function create_backend() {
    setup_heroku_backend
    npx create-strapi-app backend --quickstart &
    sleep 60 && cd backend && node ../jq_scripts/jq_backend_before.js
    wait
    setup_backend_deploy
    printf '%s\n' 'package-lock.json' >>.gitignore
    echo '.gitignore updated!'
    echo ''
    node ../jq_scripts/jq_backend_after.js
    command -v yarn >/dev/null 2>&1 || {
        echo >&2 "Yarn must be installed. Installing via NPM..."
        npm install --global yarn
    }
    yarn install
    cd ..
}

function setup_heroku_frontend() {
    echo 'Setting up frontend...'
    echo ''
    frontend_name="$dir_name-$user-frontend"
    heroku create $frontend_name
    heroku pipelines:add $dir_name -a $frontend_name -s production
    git remote remove heroku
    heroku git:remote -a $frontend_name -r heroku-frontend
    backend_url="https://$backend_name.herokuapp.com"
    heroku config:set REACT_APP_API_URL=$backend_url --remote heroku-frontend
    echo ''
    echo 'Frontend is ready for deploy!'
}

function setup_frontend_deploy() {
    cp ../frontend_config/app.js ./
    cp ../frontend_config/.env ./
    rm -rf src && cp -R ../frontend_config/src ./
}

function create_frontend() {
    setup_heroku_frontend
    npx create-react-app frontend
    cd frontend && node ../jq_scripts/jq_frontend.js
    setup_frontend_deploy
    printf '%s\n' 'package-lock.json' '.env' >>.gitignore
    echo '.gitignore updated!'
    npm install express http-server --save
    yarn install
    setup_frontend_deploy
    echo 'Frontend Created!'
    cd ..
}

function push_project() {
    cd ../$dir_name
    rm -rf ./jq_scripts
    rm -rf ./backend_config
    rm -rf ./frontend_config
    npm run commit-origin && echo 'Commit succeeded' || echo 'Commit failed'
}

function deploy_project() {
    echo ''
    echo 'Deploying project...'
    npm run full-deploy && echo 'Deploy completed with success!' || echo 'Deploy failed!'
}

function finish() {
    echo ''
    echo 'Project created with success!'
    echo ''
    echo "Project location: ${PWD}"
    echo ''
    echo 'Thank you for using Strapi & React project setup!'
    echo ''
    echo 'Bye! :)'
}

function setup() {
    welcome
    node_version
    project_init
    create_backend
    create_frontend
    push_project
    deploy_project
    finish
}

setup
