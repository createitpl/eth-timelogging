'use strict'

require('dotenv').config()

const express = require('express')
const bodyParser = require('body-parser')

const Database = require('./app/core/database')

let database = new Database({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASS,
    database: process.env.MYSQL_DB
})

let app = express()

app.use('/logs/new', bodyParser.json())
app.use('/logs/validate/id/:id', bodyParser.urlencoded({extended: false}))

require('./app/routes')(app, database)

app.listen(8080, () => {
    console.log('Listening for requests on port 8000')
})