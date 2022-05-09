// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IVote{

    function ownerOf(uint256 tokenId) external view returns(address);

    function balanceOf(address addr) external view returns(uint);


    function totalSupply() external view returns(uint);

    function approve(address to, uint256 tokenId) external;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    function transfer(address from, address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function getApproved(uint256 _tokenId) external view returns (address);

    function  setPriorVotes (address[] memory addr,uint [] memory ratio) external;

    function getcommissionedVotes(address addr,uint campaignId) external view returns (uint);

    function subcommissionedVotes(address addr,uint campaignId,uint amount) external;

    function getDelegateVote(uint campaignId) external view  returns(uint);

}
