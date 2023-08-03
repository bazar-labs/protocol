// SPDX-License-Identifier: UNLICENSED

// U _____ u  _            ____    U  ___ u   ____     _                  _   _     U  ___ u
// \| ___"|/ |"|        U /"___|u   \/"_ \/U | __")u  |"|        ___     | \ |"|     \/"_ \/
//  |  _|" U | | u      \| |  _ /   | | | | \|  _ \/U | | u     |_"_|   <|  \| |>    | | | |
//  | |___  \| |/__      | |_| |.-,_| |_| |  | |_) | \| |/__     | |    U| |\  |u.-,_| |_| |
//  |_____|  |_____|      \____| \_)-\___/   |____/   |_____|  U/| |\u   |_| \_|  \_)-\___/
//  <<   >>  //  \\       _)(|_       \\    _|| \\_   //  \\.-,_|___|_,-.||   \\,-.    \\
// (__) (__)(_")("_)     (__)__)     (__)  (__) (__) (_")("_)\_)-' '-(_/ (_")  (_/    (__)

pragma solidity ^0.8.13;

import "./BaseBehavior.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract PurchaseItemEth is BaseBehavior, Owned, Initializable {
    mapping(uint256 => uint256) public prices;

    event CurrencyPurchased(
        address indexed player, uint256 indexed itemDefinitionID, uint256 amount
    );

    event PriceSet(uint256 indexed itemDefinitionID, uint256 indexed price);

    constructor(
        address _owner,
        address inventoryController_,
        IInventoryRegistry inventoryRegistry_
    ) Owned(_owner) BaseBehavior(inventoryController_, inventoryRegistry_) {}

    function init(bytes calldata data) external payable initializer {
        (owner, inventoryController, inventoryRegistry) =
            abi.decode(data, (address, address, IInventoryRegistry));
    }

    function setPriceForCurrency(uint256 itemDefinitionID, uint256 price)
        public
        onlyOwner
    {
        prices[itemDefinitionID] = price;
    }

    function execute(address player, bytes calldata data)
        public
        payable
        override
        onlyGame
    {
        (uint256 itemDefinitionID, uint256 amount) =
            abi.decode(data, (uint256, uint256));
        uint256 price = prices[itemDefinitionID];

        require(price > 0, "Price for the item is not set");

        require(
            msg.value == price * amount, "Insufficient funds to purchase item"
        );

        // Mint the purchased item to the player
        // Assume that `mintTo` function requires definitionId instead of tokenId
        inventoryRegistry.mintTo(player, amount, itemDefinitionID, true);

        emit CurrencyPurchased(player, itemDefinitionID, 1);
    }
}
