// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiAssetContract {
    address private owner;
    mapping(address => mapping(address => uint256)) private tokenBalance;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed receiver, uint256 amount);
    event DepositToken(
        address indexed token,
        address indexed sender,
        uint256 amount
    );
    event WithdrawToken(
        address indexed token,
        address indexed receiver,
        uint256 amount
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Failed to send Ether");
        emit Withdrawal(msg.sender, amount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function depositToken(address token, uint256 amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        tokenBalance[token][msg.sender] += amount;
        emit DepositToken(token, msg.sender, amount);
    }

    function withdrawToken(address token, uint256 amount) public {
        require(
            tokenBalance[token][msg.sender] >= amount,
            "Insufficient token balance"
        );
        tokenBalance[token][msg.sender] -= amount;
        require(
            IERC20(token).transfer(msg.sender, amount),
            "Token transfer failed"
        );
        emit WithdrawToken(token, msg.sender, amount);
    }

    function getTokenBalance(
        address token,
        address user
    ) public view returns (uint256) {
        return tokenBalance[token][user];
    }
}
