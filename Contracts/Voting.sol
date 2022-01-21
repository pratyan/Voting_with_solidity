pragma solidity ^0.8.0;


contract  Voting {

    address private Head; // have the main rights to alter
    uint8 public Threshold; // max transferVotes possible

    // Candidate type(structure)
    struct Candidate {
        bytes32 name; // short and encrypted name
        uint totalVotes;
    }

    // array to keep track of the number votes to their respective candidates
    Candidate[] public billBoard;


    // Creating "Voter" type(structure)
    struct Voter {
        address voterAddress; //store voter's address
        bool voted; // track if voted
        uint8 serialNo; // index toWhom Voted
        uint8 votingStrength; // number of votes they can give
        address transferVote; // can transfer the vote to someone

    }

    // mapping voters by address
    mapping(address => Voter) public voters;


    //Constructor
    constructor(string[] memory _candidates, uint8 _threshold) {
        Head = msg.sender; // assigning the contract deployer, the Head
        voters[Head].votingStrength = 1; // giving Head, voting power
        Threshold = _threshold; // max transferVotes possible

        // listing the candisates to the billBoard
        for (uint i = 0; i < _candidates.length; i++) {
                billBoard.push(Candidate({
                    name: keccak256(abi.encodePacked(_candidates[i])),  //used keccak256 to Hash/encode the candidates names
                    totalVotes: 0
                    }));
            }

    }

    // to check accessibility
    modifier onlyHead() {
        require(msg.sender == Head,
        "Sorry you are not authorised. !!");
        _;
    }

    // to change Head
    function changeHead(address _newHead) onlyHead public {
        Head = _newHead;
    }

    // to change Threshold
    function changeThreshold(uint8 _newThreshold) onlyHead public {
        Threshold = _newThreshold;
    }


    // give access to vote
    function giveRightToVote(address voter) onlyHead public {
        //check if already voted
        require(
            !voters[voter].voted,
            "The voter already voted."
        );

        //check if RightToVote has already given
        require(voters[voter].votingStrength == 0, "RightToVote has already given");
        voters[voter].votingStrength = 1;
    }




    



}
