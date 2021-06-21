#!/bin/bash

function welcome() {
    echo 'Welcome to Strapi & React project setup!'
    echo ''
}

function check_node() {
    lowest_version="10.16.0"
    highest_version="14.0.0"
    if-node-version "<$lowest_version" && echo "Node Version must be at least $lowest_version" && echo '' && exit 1
    if-node-version ">$highest_version" && echo "Node Version can't be higher than $highest_version" && echo '' && exit 1
}

function node_version() {
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
    npm install node-jq concurrently --save
    read -p 'Repository URL: ' repository_url
    if [ -z "$repository_url" ]; then
        error_on_read read_repository_url
    else
        replace_packagejson
    fi
}

function read_heroku_backend() {
    read -p 'Heroku Backend URL: ' heroku_backend
    if [ -z "$heroku_backend" ]; then
        error_on_read read_heroku_backend
    else
        replace_packagejson
    fi
}

function read_heroku_frontend() {
    read -p 'Heroku Frontend URL: ' heroku_frontend
    if [ -z "$heroku_frontend" ]; then
        error_on_read read_heroku_frontend
    else
        replace_packagejson
    fi
}

function replace_packagejson() {
    node ./jq_scripts/jq_general.js $repository_url $heroku_backend $heroku_frontend
}

function project_init() {
    create_dir
    echo 'Initiating npm & git project...'
    cp -R strapi-react-project-setup/jq_scripts $dir_name
    echo "Scripts copied to $dir_name!"
    cd $dir_name
    echo ''
    npm init -y
    git init
    printf '%s\n' 'node_modules' 'package-lock.json' '.DS_Store' 'jq_scripts' >>.gitignore
    echo ''
    read_repository_url
    npm run setup-remotes
}

function setup_backend_for_deploy() {
    echo 'Setting up backend...'
    echo ''
    heroku addons:create heroku-postgresql:hobby-dev
    heroku config
    npm install pg-connection-string pg --save
    mkdir -p ./config/env/production
    heroku config:set NODE_ENV=production
    heroku config:set MY_HEROKU_URL=$(heroku info -s | grep web_url | cut -d= -f2)
    echo ''
    echo 'Backend is ready for deploy!'
    echo ''
}

function create_backend() {
    read_heroku_backend
    npx create-strapi-app backend --quickstart &
    sleep 10 && cd backend && node ../jq_scripts/jq_backend_before.js
    wait
    printf '%s\n' 'package-lock.json' >>.gitignore
    echo '.gitignore updated!'
    echo ''
    setup_backend_for_deploy
    node ../jq_scripts/jq_backend_after.js
    cd ..
}

function create_frontend() {
    read_heroku_frontend
    npx create-react-app frontend
    cd frontend && node ../jq_scripts/jq_frontend.js
    echo 'Frontend Created!'
    cd ..
}

function push_project() {
    cd ../$dir_name
    rm -rf jq_scripts
    npm run commit-origin
}

function run() {
    echo ''
    echo 'Project created with success!'
    echo ''
    echo "Project location: ${PWD}"
    echo ''
    echo 'Opening project...'
    echo ''
    npm run dev
}

function setup() {
    welcome
    node_version
    project_init
    create_backend
    create_frontend
    push_project
    run
}

setup
