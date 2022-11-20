// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";                                       
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/ProjectOpenSea/operator-filter-registry/blob/main/src/OperatorFilterer.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

//      ____       _ _______ _           
//     |  _ \     (_)__   __| |          
//     | |_) |_ __ _   | |  | |__   __ _ 
//     |  _ <| '__| |  | |  | '_ \ / _` |
//     | |_) | |  | |  | |  | | | | (_| |
//     |____/|_|  |_|  |_|  |_| |_|\__,_|
//   _____                  _         _____             
//  / ____|                | |       / ____|            
// | |     _ __ _   _ _ __ | |_ ___ | |  __ _   _ _   _ 
// | |    | '__| | | | '_ \| __/ _ \| | |_ | | | | | | |
// | |____| |  | |_| | |_) | || (_) | |__| | |_| | |_| |
//  \_____|_|   \__, | .__/ \__\___/ \_____|\__,_|\__, |
//               __/ | |                           __/ |
//              |___/|_|                          |___/     

contract Kitties is ERC1155, Ownable, OperatorFilterer, PaymentSplitter {

    string public name;
    string public symbol;
    uint16 public max_total;
    uint16 public total;
    uint256 public price;
    bool public paused;

    address constant DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    address[] payees = [
        0xe397f52048e00C4b7377683A392edd80cE91AD02,
        0xb97bA7C818a51106a7452ebc20751C1788C72323,
        0xB2bc6ed32660B612802E7FeC9854b16752F6b769
    ];
    uint256[] split = [
        30,
        10,
        60
    ];

    constructor ()
    ERC1155("ipfs://bafybeiau5q7tscaqg6lgd6axs6z2x6qdkcl7bis5nfe4hukbp4fwjs3sym/metadata.json")
    OperatorFilterer(DEFAULT_SUBSCRIPTION, true)
    PaymentSplitter(payees, split) {

        name = "kiTties";
        symbol = "KTS";
        max_total = 188;
        total = 0;
        price = 0.03 ether; 
        paused = false;        

    }

    function setMaxTotal(uint16 _new_max_total) external onlyOwner {

        max_total = _new_max_total;

    } 

    function setTokenUri(string calldata _new_uri) external onlyOwner {

        _setURI(_new_uri); //Sets the uri on the parent 1155 contract

    }

    function setPaused(bool _state) external onlyOwner {

        paused = _state;

    }

    function setPrice(uint256 _new_price) external onlyOwner {

        price = _new_price;
        
    }

    function mint(uint16 _mint_amount) external payable {

        require(!paused, "ERR:CP"); //Error => Contract Paused
        require((_mint_amount + total) <= max_total, "ERR:AO"); //Error => Amount Overflow 

        if (msg.sender != owner()) {

            require(msg.value >= price, "ERR:UP"); //Error => Under Priced 

        }
        total += _mint_amount;
        _mint(msg.sender, 1, _mint_amount, "");

    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }    

}
