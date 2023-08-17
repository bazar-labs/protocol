// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "solidstate-solidity/token/ERC1155/SolidStateERC1155.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract InventoryRegistry is SolidStateERC1155, Owned, Initializable {
    uint256 private _itemDefID = 1;
    uint256 private _tokenID = 1;

    mapping(uint256 => string) public itemDefIDToURI;
    mapping(uint256 => uint256[]) public itemDefIDToTokenIDs;
    mapping(uint256 => bool) public isItemDefinitionIDPublished;

    event ItemDefinitionCreated(uint256 indexed itemDefID, uint256 indexed tokenID, string indexed itemDefURI);

    event ItemDefinitionUpdated(uint256 indexed itemDefID, string indexed oldItemDefURI, string indexed newItemDefURI);

    event PublishStateUpdated(uint256 indexed itemDefID, bool indexed publishStatus);

    constructor(address _owner) Owned(_owner) SolidStateERC1155() {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    function createItemDefinition(string calldata itemDefURI) external onlyOwner {
        itemDefIDToURI[_itemDefID] = itemDefURI;
        itemDefIDToTokenIDs[_itemDefID].push(_tokenID);
        emit ItemDefinitionCreated(_itemDefID, _tokenID, itemDefURI);
        _itemDefID++;
        _tokenID++;
    }

    function updateItemDefinition(uint256 itemDefID, string calldata newItemDefURI) external onlyOwner {
        string memory oldItemDefURI = itemDefIDToURI[itemDefID];
        itemDefIDToURI[itemDefID] = newItemDefURI;
        emit ItemDefinitionUpdated(_tokenID, oldItemDefURI, newItemDefURI);
    }

    function setPublishStatus(uint256 itemDefID, bool publishStatus) external onlyOwner {
        isItemDefinitionIDPublished[itemDefID] = publishStatus;
        emit PublishStateUpdated(itemDefID, publishStatus);
    }

    function burnFrom(address player, uint256 tokenID, uint256 amount) public {
        require(isApprovedForAll(player, msg.sender), "Caller is not approved");
        _burn(player, tokenID, amount);
    }

    function mintTo(address to, uint256 amount, uint256 itemDefID, bool isFungible) public onlyOwner returns (uint256 mintedTokenID) {
        if (isFungible) {
            uint256 existingTokenID = itemDefIDToTokenIDs[itemDefID][0];
            _mint(to, existingTokenID, amount, "");
            return existingTokenID;
        } else {
            _mint(to, _tokenID, amount, "");
            _tokenID++;
            return _tokenID - 1;
        }
    }
}
