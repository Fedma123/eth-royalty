pragma solidity ^0.4.21;

contract Royalty {
    address owner;

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Royalty() public {
        owner = msg.sender;
    }

    function Buy() public payable {}

    function Withdraw() public OnlyOwner {
        owner.transfer(address(this).balance);
    }
}
