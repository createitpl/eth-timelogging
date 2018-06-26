'use strict'

const Joi = require('joi')

module.exports = Joi.object().keys({
    user: Joi.string().email().required(),
    task: Joi.string().required(),
    start: Joi.date().timestamp().required(),
    end: Joi.date().timestamp().required()
})