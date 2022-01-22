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

    //to add further candidates
    function addCandidate(string memory _name) onlyHead public {
        billBoard.push(Candidate({
                    name: keccak256(abi.encodePacked(_name)),  //used keccak256 to Hash/encode the candidates names
                    totalVotes: 0
                    }));
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


    function TransferVote(address to) public {
        // storing the function caller to sender
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        //transfering the given vote to the last node("voter") in this chain, if any
        while (voters[to].transferVote != address(0)) {
            to = voters[to].transferVote;

            //found a loop in the transferVote , not allowed.
            require(to != msg.sender, "Found loop.");
        }

        // CHECKING if the votingStrength of the given voter is full
        require(voters[to].votingStrength <= Threshold, "the given address's votingStrength is at its limit");

        sender.voted = true;
        sender.transferVote = to;

        Voter storage _to = voters[to];
        if (_to.voted) {
            // if already voted,
            // directly add to the number of votes
            billBoard[_to.serialNo].totalVotes += sender.votingStrength;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            _to.votingStrength += sender.votingStrength;
        }
    }

    // voting function
    function vote(uint8 _serialNo) public {
        // storing the function caller to sender
        Voter storage sender = voters[msg.sender];

        //CHECKING
        require(sender.votingStrength != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");

        sender.voted = true;
        sender.serialNo = _serialNo;

        // If '_serialNo' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        billBoard[_serialNo].totalVotes += sender.votingStrength;
    }



    //computes the winner and returns its "billBoard" index/ serialNo
     function getWinnerSerialNo() public view
            returns (uint winner_)
    {
        uint winningVoteCount = 0;

        //iterates through the billBoard and stores indexOf the best totalVotes
        for (uint p = 0; p < billBoard.length; p++) {
            if (billBoard[p].totalVotes > winningVoteCount) {
                winningVoteCount = billBoard[p].totalVotes;
                winner_ = p;
            }
        }
    }



    //  Calls getWinnerSerialNo() function to get the index of the winner 
    //  then returns the encoded name of the winner
    function winnerEncodedName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = billBoard[getWinnerSerialNo()].name;
    }

}
