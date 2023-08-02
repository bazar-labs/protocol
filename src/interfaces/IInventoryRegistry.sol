// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IInventoryRegistry {
    event ApprovalForAll(
        address indexed account, address indexed operator, bool approved
    );
    event Initialized(uint8 version);
    event ItemDefinitionCreated(
        uint256 indexed itemDefID,
        uint256 indexed tokenID,
        string indexed itemDefURI
    );
    event ItemDefinitionUpdated(
        uint256 indexed itemDefID,
        string indexed oldItemDefURI,
        string indexed newItemDefURI
    );
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event URI(string value, uint256 indexed tokenId);

    function accountsByToken(uint256 id)
        external
        view
        returns (address[] memory);
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        external
        view
        returns (uint256[] memory);
    function burnFrom(address player, uint256 tokenID, uint256 amount)
        external;
    function createItemDefinition(string memory itemDefURI) external;
    function init(bytes memory data) external payable;
    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);
    function itemDefIDToTokenIDs(uint256, uint256)
        external
        view
        returns (uint256);
    function itemDefIDToURI(uint256) external view returns (string memory);
    function mintTo(
        address to,
        uint256 amount,
        uint256 itemDefID,
        bool isFungible
    ) external returns (uint256 mintedTokenID);
    function owner() external view returns (address);
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
    function setApprovalForAll(address operator, bool status) external;
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool);
    function tokensByAccount(address account)
        external
        view
        returns (uint256[] memory);
    function totalHolders(uint256 id) external view returns (uint256);
    function totalSupply(uint256 id) external view returns (uint256);
    function transferOwnership(address newOwner) external;
    function updateItemDefinition(
        uint256 itemDefID,
        string memory newItemDefURI
    ) external;
    function uri(uint256 tokenId) external view returns (string memory);
}
