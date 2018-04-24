pragma solidity ^0.4.23;

contract Royalty {
    address owner;
    string public resourceHash;
    string public resourceName; 
    //May be used to prove the owner was the first to "register"
    //the resource in case of a dispute.
    uint public contractMinedTimestamp;
    uint256 public minimumPriceWei;

    mapping (address=>uint256) payers;
    address[] payersIndex;

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(string resHash, string resName, uint256 minimumPriceInWei) public {
        owner = msg.sender;
        resourceHash = resHash;
        resourceName = resName;        
        contractMinedTimestamp = block.timestamp;
        minimumPriceWei = minimumPriceInWei;
    }

    //Allows the sender to purchase the royalty by sending
    //at least the minimum amount required. If the sender
    //has not already payed he is added in a payers collection
    function Purchase() public payable {
        require(msg.value >= minimumPriceWei);

        if (!HasAlreadyPaid(msg.sender))
            payers[msg.sender] = payersIndex.push(msg.sender) - 1;
    }

    function Withdraw() public OnlyOwner {
        owner.transfer(address(this).balance);
    }

    function HasAlreadyPaid(address account) public view returns (bool) {
        if (payersIndex.length == 0)
            return false;

        return (payersIndex[payers[account]] == account);
    }
}
