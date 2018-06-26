'use strict'

const timelog_routes = require('./timelog_routes')

module.exports = (app, client) => {
    timelog_routes(app ,client)
}