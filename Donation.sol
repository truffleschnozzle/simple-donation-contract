// SPDX-License-Identifier: Unlicense

pragma solidity >=0.8.0 <0.9.0;

contract Donation {
    address public owner;
    address public administrator;
    address public beneficiary;
    uint256 public fund;

    constructor(address _administrator) {
        owner = msg.sender;
        administrator = _administrator;
    }

    function updateAdministrator(address _administrator) external {
        require(msg.sender == owner, "Only owner can update administrator");
        require(address(this).balance == 0, "Fundraising in progress");
        administrator = _administrator;
    }

    function updateBeneficiary(address _beneficiary) external {
        require(msg.sender == administrator, "Only beneficiary can withdraw funds");
        require(address(this).balance == 0, "Fundraising in progress");
        beneficiary = _beneficiary;
    }

    function closeDonations() internal {
        require(address(this).balance == 0, "Fundraising in progress");
        beneficiary = address(0);
        administrator = address(0);
    }

    function deposit() external payable {
        require(beneficiary != address(0), "No fundraiser in progress");
        uint adminFee = msg.value * 1 / 100;
        (bool sent, ) = payable(administrator).call{value: adminFee}("");
        require(sent == true, "Transfer failed");
        fund += (msg.value - adminFee);
    }

    function withdraw() external {
        require(msg.sender == beneficiary, "Only beneficiary can withdraw");
        (bool sent, ) = payable(beneficiary).call{value: fund}("");
        require(sent == true, "Transfer failed");
        fund = 0;
        closeDonations();
    }

    receive() external payable {
        require(beneficiary != address(0), "No fundraiser in progress");
        uint transactionFee = msg.value * 1 / 100;
        (bool sent, ) = payable(administrator).call{value: transactionFee}("");
        require(sent == true, "Transfer failed");
        fund += (msg.value - transactionFee);
    }
    // function blowmeup() is set for development purposes only
    function blowmeup() external {
        require(msg.sender == owner, "Must be owner to destroy contract");
        (bool sent, ) = payable(owner).call{value: fund}("");
        require(sent == true, "Transfer failed");
    }
}
