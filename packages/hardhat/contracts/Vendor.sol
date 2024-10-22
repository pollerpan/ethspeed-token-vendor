pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { YourToken } from "./YourToken.sol";

contract Vendor is Ownable {
	error Vendor_NotEnoughTokens();
	error Vendor_WithdrawakFailed();
	error Vendor_NotFundsTowithdraw();

	// event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	uint256 public constant tokensPerEth = 100;

	event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfEth
	);

	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		uint256 amountOfTokens = msg.value * tokensPerEth;
		if (yourToken.balanceOf(address(this)) < amountOfTokens) {
			revert Vendor_NotEnoughTokens();
		}
		yourToken.transfer(msg.sender, amountOfTokens);

		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() external onlyOwner {
		uint256 amountOfETH = address(this).balance;
		if (amountOfETH == 0) {
			revert Vendor_NotFundsTowithdraw();
		}
		(bool success, ) = msg.sender.call{ value: address(this).balance }("");
		if (!success) {
			revert Vendor_WithdrawakFailed();
		}
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) public {
		require(_amount > 0, "Amount must be greater than 0");

		bool sentTokens = yourToken.transferFrom(
			msg.sender,
			address(this),
			_amount
		);
		require(sentTokens, "Token transfer failed");

		require(tokensPerEth > 0, "Inavalid tokens per eth");
		uint256 amountOfEth = _amount / tokensPerEth;

		require(address(this).balance >= amountOfEth, "Not enough ETH");
		(bool sentEth, ) = payable(msg.sender).call{ value: amountOfEth }("");
		require(sentEth, "ETH transfer failed");
		emit SellTokens(msg.sender, _amount, amountOfEth);
	}
}
