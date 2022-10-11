// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SimpleStorage {
    // just like a class

    // Here we have some options for data types
    //bool favoriteBool = true;
    //string favoriteString = "String";
    //int256 favoriteInt = -5;
    //address favortieAddress = 0x5635842bd632C27D221598763581331D3F117C1f;
    // bytes32 favoriteBytes = "cat";

    uint256 favoriteNumber; //this will get initialised as 0

    struct People {
        uint256 favoriteNumber;
        string name;
    }

    // People public person = People({favoriteNumber: 2, name: "David"}); Thats how you create one person

    // But we want to have a list of people - This can be done with arrays

    // array
    People[] public people; //It's a People array and we call it people - [] = variable array - [1] fixed size of 1 (only one entry allowed)

    // mapping
    // A dictionary like data structure with 1 value per key
    mapping(string => uint256) public nameToFavoriteNumber; // the string is going to be mapped to uint256

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
        // uint test = 4; //this is a local variable, can only be used within the function
    }

    // view & pure:
    // view is only to read some state of the blockchain - since we only read from blockchain, we do not pay any gas for it
    // pure fuctions are functions that purely do some math - but we do not save anything - state of blockchain it not changed
    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    //function retrieve_pure(uint favoriteNumber) public pure {
    //    return favoriteNumber + favoriteNumber;
    //}

    // memory: data will only be stored during the execution of the function
    // storage: data will be persist even after the function was executed
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        people.push(People({favoriteNumber: _favoriteNumber, name: _name})); // Add person to array
        nameToFavoriteNumber[_name] = _favoriteNumber; // We are going to map the name to the favorite number - mapping
    }

    // mappings
    // What if I'm looking for a person?
}
