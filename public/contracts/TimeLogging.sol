pragma solidity ^0.4.23;

import './Ownable.sol';

contract TimeLogging is Ownable {
    struct Checksum {
        string value;
        uint createdAt;
        uint8 isSet;
    }

    mapping(uint => Checksum) public idToChecksum;

    uint totalChecksums = 0;

    event ChecksumAdded(uint attemptedAt, uint logId);

    function addLogChecksum(string _checksum) external onlyOwner {
        // Check if this is the most gas efficient way to save a new struct
        // to mapping.
        // It's possible that creating a struct in memory and saving it once
        // to mapping is better than saving 3 attributes separately.
        idToChecksum[totalChecksums].value = _checksum;
        idToChecksum[totalChecksums].createdAt = now;
        idToChecksum[totalChecksums].isSet = 1;
        // However unlikely it is possible that this counter will reach
        // it's limit and roll over back to 0
        // without the SafeMath library. Consider adding SafeMath and stopping
        // the truffle after the limit is reached.
        totalChecksums++;
        emit ChecksumAdded(now, totalChecksums);
    }

    function getTotalChecksums() public view returns (uint) {
        return totalChecksums;
    }

    function getChecksumById(uint _id) public view returns (string, uint, uint8) {
        return (idToChecksum[_id].value, idToChecksum[_id].createdAt, idToChecksum[_id].isSet);
    }
}
