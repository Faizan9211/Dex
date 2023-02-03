// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Dexes is ERC20,Ownable,ERC721Holder{
    struct Token{
        IERC20 token1;
        IERC20 token2;
        uint cost1;
        uint cost2;
    }

    Token[] public tokenLiquid;
    uint stakingAmount=100*10**18;
    uint public noOfStaker;
    uint public noOfliquidator;
    mapping(address=>uint) swapAmount;
    mapping(address=>uint) stakeCustomerAmount;  
    mapping(address=>uint[]) nftStakeAmount;

    constructor()ERC20("Faizi", "KMF"){
    }

    function stakingToken(IERC20 _token,uint amount) public{
        _token.transferFrom(msg.sender,address(this),amount);
        if(stakeCustomerAmount[msg.sender]==0){
            noOfStaker++;
        }
        stakeCustomerAmount[msg.sender]+=amount;
        _mint(msg.sender,stakingAmount);
    }

    function unstake(IERC20 _token,uint amount,IERC20 token) public{
        require(amount>0,"insuuficiant");
        require(amount==stakeCustomerAmount[msg.sender],"tera pas itna paisa nai ha");
        token.approve(address(this),amount);
        token.transferFrom(msg.sender,address(this),amount);
        _token.transfer(msg.sender,stakeCustomerAmount[msg.sender]);
        stakeCustomerAmount[msg.sender]=0;
    }

    function nftStaking(IERC721 _nft,uint tokenId) public {
        _nft.safeTransferFrom(msg.sender,address(this),tokenId);
        nftStakeAmount[msg.sender].push(tokenId);
        _mint(msg.sender,stakingAmount);
    }

    function nftUnstaking(IERC721 _nft,uint tokenId,uint _amount,IERC20 token) public{
        require(_amount>=stakingAmount,"your not able to request");
        token.approve(address(this),_amount);
        token.transferFrom(msg.sender,address(this),_amount);
        _nft.transferFrom(address(this),msg.sender,tokenId);
        for(uint i=0;i<nftStakeAmount[msg.sender].length;i++){
            if(nftStakeAmount[msg.sender][i]==tokenId){
                nftStakeAmount[msg.sender][i]=nftStakeAmount[msg.sender][nftStakeAmount[msg.sender].length-1];
                nftStakeAmount[msg.sender].pop();
            }
        }
    }

    function liquidityProvide(IERC20 _token1,IERC20 _token2,uint _cost1,uint _cost2) public {
        _token1.approve(address(this),_cost1);
        _token2.approve(address(this),_cost2);
        _token1.transferFrom(msg.sender,address(this),_cost1);
        _token2.transferFrom(msg.sender,address(this),_cost2);
        tokenLiquid.push(Token({
            token1:_token1,
            token2:_token2,
            cost1:_cost1,
            cost2:_cost2
        }));
        noOfliquidator++;
    } 

    function swap(IERC20 token,uint amount,IERC20 _token) public {
        token.approve(address(this),amount);
        token.transferFrom(msg.sender,address(this),amount);
        _token.transfer(msg.sender,amount/2);
        swapAmount[address(this)]+=amount;
    }
}

