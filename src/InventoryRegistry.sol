// SPDX-License-Identifier: UNLICENSED

// U _____ u  _            ____    U  ___ u   ____     _                  _   _     U  ___ u
// \| ___"|/ |"|        U /"___|u   \/"_ \/U | __")u  |"|        ___     | \ |"|     \/"_ \/
//  |  _|" U | | u      \| |  _ /   | | | | \|  _ \/U | | u     |_"_|   <|  \| |>    | | | |
//  | |___  \| |/__      | |_| |.-,_| |_| |  | |_) | \| |/__     | |    U| |\  |u.-,_| |_| |
//  |_____|  |_____|      \____| \_)-\___/   |____/   |_____|  U/| |\u   |_| \_|  \_)-\___/
//  <<   >>  //  \\       _)(|_       \\    _|| \\_   //  \\.-,_|___|_,-.||   \\,-.    \\
// (__) (__)(_")("_)     (__)__)     (__)  (__) (__) (_")("_)\_)-' '-(_/ (_")  (_/    (__)

pragma solidity ^0.8.13;

import "solidstate-solidity/token/ERC1155/SolidStateERC1155.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/proxy/utils/Initializable.sol";

contract InventoryRegistry is SolidStateERC1155, Owned, Initializable {
    constructor(address _owner) Owned(_owner) SolidStateERC1155() {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    uint256 private tokenId = 1;
    uint256 private definitionId = 1;

    // mapping(uint256 itemDefinitionId => string definitionUri)
    //     public definitionIdToUri;
    // mapping(uint256 itemDefinitionId => uint256[] tokenIds)
    //     public definitionIdToTokenIds;
    // mapping(uint256 tokenId => uint256 itemDefinitionId)
    //     public tokenIdToDefinitionId;

    mapping(uint256 => string) public definitionIdToUri;
    mapping(uint256 => uint256[]) public definitionIdToTokenIds;
    mapping(uint256 => uint256) public tokenIdToDefinitionId;
    mapping(uint256 => string) public tokenIdToAttribute;

    event SetTokenDefinition(
        uint256 indexed tokenId, uint256 indexed definitionId
    );

    event CreatedDefinition(
        uint256 indexed definitionId,
        uint256 indexed tokenId,
        string indexed definitionUri
    );

    event UpdatedDefinition(
        uint256 indexed definitionId,
        string indexed oldDefinitionUri,
        string indexed newDefinitionUri
    );

    function createItemDefinition(string calldata definitionUri)
        external
        onlyOwner
    {
        definitionIdToUri[definitionId] = definitionUri;
        definitionIdToTokenIds[definitionId].push(tokenId);
        emit CreatedDefinition(definitionId, tokenId, definitionUri);
        definitionId++;
        tokenId++;
    }

    function updateItemDefinition(
        uint256 _definitionId,
        string calldata newDefinitionUri
    ) external onlyOwner {
        string memory oldDefinitionUri = definitionIdToUri[_definitionId];
        definitionIdToUri[_definitionId] = newDefinitionUri;
        emit UpdatedDefinition(tokenId, oldDefinitionUri, newDefinitionUri);
    }

    function setAttribute(uint256 tokenId_, string calldata attribute_)
        external
        onlyOwner
    {
        // onlyAttributor(tokenIdToDefinitionId[tokenId]) {
        tokenIdToAttribute[tokenId_] = attribute_;
    }

    function burnFrom(address player, uint256 tokenId_, uint256 amount)
        public
    {
        require(isApprovedForAll(player, msg.sender), "Caller is not approved");
        _burn(player, tokenId_, amount);
    }

    function mintTo(
        address to,
        uint256 amount,
        uint256 itemDefinitionId,
        bool isFungible
    ) public onlyOwner returns (uint256 mintedTokenId) {
        if (isFungible) {
            uint256 existingTokenId =
                definitionIdToTokenIds[itemDefinitionId][0];
            _mint(to, existingTokenId, amount, "");
            return existingTokenId;
        } else {
            _mint(to, tokenId, amount, "");
            tokenId++;
            return tokenId - 1;
        }
    }
}
