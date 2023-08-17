// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "solidstate-solidity/token/ERC1155/SolidStateERC1155.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @title InventoryRegistry
/// @notice Registry of item definitions and tokens, implements ERC-1155
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

    /// @dev Called once after cloned via factory, acts as a constructor
    /// @param data ABI-encoded address of owner
    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    /// @notice Creates a new item definition
    /// @param URI URI of the item definition
    function create(string calldata URI) external onlyOwner {
        itemDefinitionIDToURI[_itemDefinitionID] = URI;
        itemDefinitionIDToTokenIDs[_itemDefinitionID].push(_tokenID);
        emit ItemDefinitionCreated(_itemDefinitionID, _tokenID, URI);
        _itemDefinitionID++;
        _tokenID++;
    }

    /// @notice Updates the URI of an item definition
    /// @param itemDefinitionID ID of the item definition
    /// @param newURI New URI of the item definition
    function update(uint256 itemDefinitionID, string calldata newURI) external onlyOwner {
        string memory oldURI = itemDefinitionIDToURI[itemDefinitionID];
        itemDefinitionIDToURI[itemDefinitionID] = newURI;
        emit ItemDefinitionUpdated(itemDefinitionID, oldURI, newURI);
    }

    /// @notice Publishes an item definition, allowing it to be minted
    /// @param itemDefinitionID ID of the item definition
    function publish(uint256 itemDefinitionID) external onlyOwner {
        isItemDefinitionIDPublished[itemDefinitionID] = true;
        emit ItemDefinitionPublished(itemDefinitionID);
    }

    /// @notice Unpublishes an item definition, preventing it from being minted
    /// @param itemDefinitionID ID of the item definition
    function unpublish(uint256 itemDefinitionID) external onlyOwner {
        isItemDefinitionIDPublished[itemDefinitionID] = false;
        emit ItemDefinitionUnpublished(itemDefinitionID);
    }

    /// @notice Mints a fungible or non-fungible token to a player based on an item definition
    /// @param to Address of the player to mint to
    /// @param amount Amount of tokens to mint
    /// @param itemDefinitionID ID of the item definition
    /// @param isFungible Whether or not the token is fungible
    function mint(address to, uint256 amount, uint256 itemDefinitionID, bool isFungible) public onlyOwner {
        if (isFungible) {
            uint256 existingTokenID = itemDefinitionIDToTokenIDs[itemDefinitionID][0];
            _mint(to, existingTokenID, amount, "");
        } else {
            _mint(to, _tokenID, amount, "");
            _tokenID++;
        }
    }

    /// @notice Burns a token from a player
    /// @param player Address of the player to burn from
    /// @param tokenID ID of the token to burn
    /// @param amount Amount of tokens to burn
    function burn(address player, uint256 tokenID, uint256 amount) public {
        require(isApprovedForAll(player, msg.sender), "Caller is not approved");
        _burn(player, tokenID, amount);
    }
}
