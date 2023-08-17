// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "solidstate-solidity/token/ERC1155/SolidStateERC1155.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract InventoryRegistry is SolidStateERC1155, Owned, Initializable {
    uint256 private _itemDefinitionID = 1;
    uint256 private _tokenID = 1;

    mapping(uint256 => string) public itemDefinitionIDToURI;
    mapping(uint256 => uint256[]) public itemDefinitionIDToTokenIDs;
    mapping(uint256 => bool) public isItemDefinitionIDPublished;

    event ItemDefinitionCreated(uint256 indexed itemDefinitionID, uint256 indexed tokenID, string indexed URI);
    event ItemDefinitionUpdated(uint256 indexed itemDefinitionID, string indexed oldURI, string indexed newURI);
    event ItemDefinitionPublished(uint256 indexed itemDefinitionID);
    event ItemDefinitionUnpublished(uint256 indexed itemDefinitionID);

    constructor(address _owner) Owned(_owner) SolidStateERC1155() {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    function create(string calldata URI) external onlyOwner {
        itemDefinitionIDToURI[_itemDefinitionID] = URI;
        itemDefinitionIDToTokenIDs[_itemDefinitionID].push(_tokenID);
        emit ItemDefinitionCreated(_itemDefinitionID, _tokenID, URI);
        _itemDefinitionID++;
        _tokenID++;
    }

    function update(uint256 itemDefinitionID, string calldata newURI) external onlyOwner {
        string memory oldURI = itemDefinitionIDToURI[itemDefinitionID];
        itemDefinitionIDToURI[itemDefinitionID] = newURI;
        emit ItemDefinitionUpdated(itemDefinitionID, oldURI, newURI);
    }

    function publish(uint256 itemDefinitionID) external onlyOwner {
        isItemDefinitionIDPublished[itemDefinitionID] = true;
        emit ItemDefinitionPublished(itemDefinitionID);
    }

    function unpublish(uint256 itemDefinitionID) external onlyOwner {
        isItemDefinitionIDPublished[itemDefinitionID] = false;
        emit ItemDefinitionUnpublished(itemDefinitionID);
    }

    function mint(address to, uint256 amount, uint256 itemDefinitionID, bool isFungible) public onlyOwner {
        if (isFungible) {
            uint256 existingTokenID = itemDefinitionIDToTokenIDs[itemDefinitionID][0];
            _mint(to, existingTokenID, amount, "");
        } else {
            _mint(to, _tokenID, amount, "");
            _tokenID++;
        }
    }

    function burn(address player, uint256 tokenID, uint256 amount) public {
        require(isApprovedForAll(player, msg.sender), "Caller is not approved");
        _burn(player, tokenID, amount);
    }
}
