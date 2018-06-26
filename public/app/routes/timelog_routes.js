'use strict'

const Joi = require('joi');
const sha256 = require('js-sha256').sha256
const timelog_schema = require('../validation/timelog_schema')
const ethereum = require('../eth/ethereum')
const Contract = require('../eth/contract')
const contract = new Contract(ethereum.contract)

module.exports = (app, database) => {
    
    /**
     * Fetch a checksum from the smart contract by its Id
     */
    app.get('/contract/checksums/:id', (req, res) => {
        contract.getChecksumById(req.params.id)
                .then(data => {
                    let response
                    if ( data[2].toNumber() === 0 ) {
                        response = {
                            status: "ERROR",
                            msg: `Checksum with id: ${req.params.id} is not commited or the transaction hasn't been mined yet.`
                        }
                    } else {
                        response = {
                            status: "OK",
                            payload: {
                                hash: data[0],
                                commited: new Date(data[1].toNumber()).toISOString()
                            }
                        }
                    }
                    res.send(response)
                })
                .catch(err => {
                    res.send({
                        status: "ERROR",
                        msg: err.message
                    })
                })
    })
    
    /**
     * Add a new log to db
     */
    app.post('/logs/new', (req, res) => {
        let doc = typeof req.body === 'string' ? JSON.parse(req.body) : req.body
        
        let valid = Joi.validate(doc, timelog_schema)
        if ( valid.error ) {
            res.send({
                status: "ERROR",
                msg: valid.error.message
            })
        }
        
        database.query(
            "INSERT INTO logs (user, task, start, end, hash_id) VALUES (?)",
            [[doc.user, doc.task, doc.start, doc.end, null]])
                .then(result => {
                    res.send(result)
                })
                .catch(err => {
                    res.send({
                        status: "ERROR",
                        msg: err.message
                    })
                })
    })
    
    /**
     * Commit a checksum of all pending logs to the smart contract
     */
    app.post('/logs/commit', (req, res) => {
        let ids = [], hash, hash_id
        
        contract.getTotalChecksums()
                .then(number => {
                    hash_id = number
                    return database.query("SELECT id, user, task, start, end FROM logs WHERE hash_id IS NULL")
                })
                .then(rows => {
                    hash = sha256(JSON.stringify(rows))
                    ids = rows.map(doc => {
                        return doc["id"]
                    })
                    if ( ids.length === 0 ) {
                        res.send({
                            msg: "No new logs to commit"
                        })
                    } else {
                        return contract.addLogChecksum(hash)
                    }
                })
                .then(() => database.query(
                    `UPDATE logs SET hash_id = "${hash_id}" WHERE id IN (?)`,
                    [ids]
                ))
                .then(result => {
                    res.send({
                        status: "OK",
                        commited_log_ids: JSON.stringify(ids),
                        hash: hash,
                        hash_id: hash_id
                    })
                })
                .catch(err => {
                    res.send({
                        status: "ERROR",
                        msg: err.message
                    })
                })
    })
    
    /**
     * Validate that the log with given hash_id and all others that have been commited together
     * and share the same hash_id are still unchanged.
     */
    app.get('/logs/validate/hashid/:id', (req, res) => {
        let hash
        console.log(req.params.id)
        database.query(`SELECT id, user, task, start, end FROM logs WHERE hash_id = "${req.params.id}"`)
                .then(rows => {
                    hash = sha256(JSON.stringify(rows))
                    return contract.verifyChecksum(req.params.id, hash)
                })
                .then(response => {
                    res.send(response)
                })
                .catch(err => {
                    res.send({
                        status: "ERROR",
                        msg: err.message
                    })
                })
    })
}