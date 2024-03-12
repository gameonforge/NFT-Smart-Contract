//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./ERC721.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./EnumerableSet.sol";

contract NFT is ERC721, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    string internal _assetUri;
    EnumerableSet.AddressSet private operators;

    modifier onlyOperator{
        require(operators.contains(_msgSender()), "Forbidden");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Ownable(_msgSender()) {
        operators.add(_msgSender());
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply();
    }

    function mint(address to, uint256 tokenId) public onlyOperator {
        _safeMint(to, tokenId);
    }

    function setOperator(address operatorAddress, bool value) public onlyOwner {
        if (value) {
            operators.add(operatorAddress);
        } else {
            operators.remove(operatorAddress);
        }
        emit OperatorSet(operatorAddress, value);
    }

    function _baseURI() internal override view virtual returns (string memory) {
        return _assetUri;
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory value) public onlyOwner {
        _assetUri = value;
    }

    function retrieveToken(address tokenAddress, uint256 amount, address receiveAddress) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(receiveAddress, amount);
    }

    function retrieveMainBalance(address receiveAddress) external onlyOwner {
        payable(receiveAddress).transfer(address(this).balance);
    }

    function withdrawNft(address nftAddress, uint256 tokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "zero address");
        IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenId);
    }

    function batchWithdrawNft(address nftAddress, uint256[] memory listTokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "zero address");
        require(listTokenId.length > 0, "EMPTY LIST TOKEN ID");
        for (uint256 index = 0; index < listTokenId.length; index++) {
            IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, listTokenId[index]);
        }
    }

    function batchTransfer(address[] memory receiveAddress, uint256[] memory listTokenId) public {
        require(receiveAddress.length == listTokenId.length, "Invalid parameter length");
        for (uint256 index = 0; index < receiveAddress.length; index++) {
            safeTransferFrom(msg.sender, receiveAddress[index], listTokenId[index]);
        }
    }

    function getOperatorLength() external view returns (uint256) {
        return operators.length();
    }

    function getOperatorAtIndex(uint256 _index) external view returns (address) {
        return operators.at(_index);
    }

    function operatorIsValid(address _address) external view returns (bool) {
        return operators.contains(_address);
    }

    event OperatorSet(address operatorAddress, bool value);

}