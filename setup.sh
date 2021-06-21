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
        mkdir $dir_name
        echo "Directory $dir_name created!"
        echo ''
    fi
}

function read_repository_url() {
    read -p 'Repository URL: ' repository_url
    if [ -z "$repository_url" ]; then
        error_on_read create_repository_url
    fi
}

function read_heroku_backend() {
    read -p 'Heroku Backend URL: ' heroku_backend
    if [ -z "$heroku_backend" ]; then
        error_on_read create_heroku_backend
    fi
}

function read_heroku_frontend() {
    read -p 'Heroku Frontend URL: ' heroku_frontend
    if [ -z "$heroku_frontend" ]; then
        error_on_read create_heroku_frontend
    fi
}

function replace_packagejson() {
    npm install node-jq concurrently --save
    echo ''
    read_repository_url
    echo ''
    read_heroku_backend
    echo ''
    read_heroku_frontend
    echo ''
    node ./jq_scripts/jq_general.js $repository_url $heroku_backend $heroku_frontend
}

function project_init() {
    create_dir
    echo 'Initiating npm & git project...'
    cp -R jq_scripts $dir_name
    echo "Scripts copied to $dir_name!"
    cd $dir_name
    echo ''
    npm init -y
    git init
    printf '%s\n' 'node_modules' 'package-lock.json' '.DS_Store' 'jq_scripts' >>.gitignore
    echo ''
    replace_packagejson
    npm run setup-remotes
}

function create_backend() {
    npx create-strapi-app backend --quickstart &
    sleep 10 && cd backend && node ../jq_scripts/jq_backend_rm_develop.js
    wait
    echo ''
    node ../jq_scripts/jq_backend_reset_develop.js
    cd ..
}

function create_frontend() {
    npx create-react-app frontend
    cd frontend && node ../jq_scripts/jq_frontend.js
    echo ''
    echo 'Frontend Created!'
    cd ..
}

function mv_dir() {
    find . -maxdepth 1 -exec mv {} .. \;
}

function run() {
    echo ''
    echo 'Project created with success!'
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
    #mv_dir
    run
}

setup
