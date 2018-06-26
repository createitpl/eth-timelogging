module.exports = class Contract {
    constructor (contractInstance) {
        this.contractInstance = contractInstance
    }
    
    getTotalChecksums () {
        return new Promise((resolve, reject) => {
            this.contractInstance.getTotalChecksums((err, result) => {
                if ( err ) return reject(err)
                resolve(result.toNumber())
            })
        })
    }
    
    addLogChecksum (hash) {
        return new Promise((resolve, reject) => {
            this.contractInstance.addLogChecksum.sendTransaction(
                hash,
                {gas: 300000},
                (err, result) => {
                    if ( err ) return reject(err)
                    resolve()
                }
            )
        })
    }
    
    getChecksumById (id) {
        return new Promise((resolve, reject) => {
            this.contractInstance.getChecksumById(id, (err, result) => {
                if ( err ) return reject(err)
                resolve(result)
            })
        })
    }
    
    verifyChecksum (id, hash) {
        return new Promise((resolve, reject) => {
            this.getChecksumById(id)
                .then(data => {
                    let response
                    if( !data[0])
                        throw new Error(`Checksum with id: ${id} is not commited or the transaction hasn't been mined yet`)
                    if ( data[0] !== hash ) {
                        response = {
                            status: "Hashes don't match",
                            commited_hash: data[0],
                            new_hash: hash,
                            commited: new Date(data[1].toNumber()).toISOString()
                        }
                    } else {
                        response = {
                            status: "OK, hash matches the commited one",
                            hash: hash,
                            commited: new Date(data[1].toNumber()).toISOString()
                        }
                    }
                    return resolve(response)
                })
                .catch(err => {
                    return reject(err)
                })
        })
    }
}