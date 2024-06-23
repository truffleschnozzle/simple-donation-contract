// SPDX-License-Identifier: Unlicense

pragma solidity >=0.8.0 <0.9.0;

contract Donation {
    address public owner;
    address public administrator;
    address public beneficiary;

    constructor(address _administrator) {
        owner = msg.sender;
        administrator = _administrator;
    }

    function updateAdministrator(address _administrator) external {
        require(msg.sender == owner, "Only owner can update beneficiary");
        administrator = _administrator;
    }

    function updateBeneficiary(address _beneficiary) external {
        require(msg.sender == administrator, "Only beneficiary can withdraw funds");
        require(address(this).balance == 0, "Cannot change beneficiary during fundraising");
        beneficiary = _beneficiary;
    }

    function deposit() external payable {
        require(beneficiary != address(0));
        uint adminFee = msg.value * 1 / 100;
        (bool sent, ) = payable(administrator).call{value: adminFee}("");
        require(sent == true, "Transfer failed");
        
    }

    function withdraw() external {
        require(msg.sender == beneficiary, "Only beneficiary can withdraw");
        (bool sent, ) = payable(beneficiary).call{value: address(this).balance}("");
        require(sent == true, "Transfer failed");
    }

    receive() external payable {
        uint donationAmount = msg.value * 1 / 100;
        (bool sent, ) = payable(beneficiary).call{value: donationAmount}("");
        require(sent == true, "Transfer failed");
    }
}
