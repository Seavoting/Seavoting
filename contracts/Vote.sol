pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interface/IVoteOracle.sol";

contract vote {

    using SafeMath for uint;

    struct OracleVote{
     address  contractAddr;
     uint     ratioFactor;
    }

    OracleVote [] oracleVoteArray;

    struct Vote{
      address owner;
      uint tokenId;
      uint crtTime;
    }

    constructor(address _rVip,address core) CoreRef(core) public {
      rvipAddr=_rVip;
    }

    Vote [] public voteArray;

    mapping (address => uint) public takenByAddr;  //uint --tokenId

    mapping (address =>mapping (uint256 =>uint)) public  originalVote;

    mapping (address =>mapping (uint256 =>uint)) public  commissionedVote;

    mapping (address =>mapping (uint256 =>uint)) public  delegateVote;

    mapping (address =>mapping(address =>mapping (uint256 =>uint))) public  toDelegateVote;

    mapping(uint => uint) public everyVoteDelegateAmount;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event DelegateEvent(uint indexed campaignId,address indexed sender,address indexed received,uint amount);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event UndoDelegateEvent(uint indexed campaignId,address indexed sender,address indexed received);

    event  ChangeShoppingAddrEvent(address indexed originAddr,address indexed newAddr);

    event  ChangeRbVipAddrEvent(address indexed originAddr,address indexed newAddr);


    function mint(address to) public returns(uint){
       require(to != address(0), "ERC721: mint to the zero address");
       require(takenByAddr[to]==0,"Additional tokens have been issued");
         uint256 newTokenId = voteArray.length+1;
             Vote memory vote = Vote({
                owner: to,
                tokenId: newTokenId,
                crtTime:block.timestamp
            });
            voteArray.push(vote);
            takenByAddr[to]=newTokenId;
            emit Transfer(address(0), to,newTokenId);
            return newTokenId;
      }



    function  setOriginalVote(address to,address govAddr,uint cityNodeId,uint blockNumber,uint campaignId) public {

        // IBlockNumber  gov =IBlockNumber(govAddr);
        // uint blockNumber=gov.getBlockNumber(cityNodeId);
        originalVote[to][campaignId]=getVoteNum(to,blockNumber);
    }


   function delegate(address from,address to,uint amount,uint campaignId) public {
        require(from==msg.sender,"have no right");
        require(originalVote[from][campaignId]-delegateVote[from][campaignId]>0,"Insufficient votes");
         commissionedVote[to][campaignId]+=amount;
         everyVoteDelegateAmount[campaignId] += amount;
         delegateVote[from][campaignId]+=amount;
         toDelegateVote[from][to][campaignId]+=amount;
         emit DelegateEvent(campaignId,from,to,amount);
   }


     function undoDelegate(address from ,address to,uint campaignId) public {

       require(from==msg.sender,"have no right");

       originalVote[from][campaignId]+=toDelegateVote[from][to][campaignId];

       delegateVote[from][campaignId]-= toDelegateVote[from][to][campaignId];

       toDelegateVote[from][to][campaignId]=0;

       everyVoteDelegateAmount[campaignId] -= toDelegateVote[from][to][campaignId];
     emit UndoDelegateEvent(campaignId,from,to);
   }


     function getBalanceOf(address addr,uint campaignId)public view returns (uint){
      return  originalVote[addr][campaignId] +commissionedVote[addr][campaignId]-delegateVote[addr][campaignId];
     }


    function ownerOf(uint256 tokenId) public view override returns(address){
      return  voteArray[tokenId-1].owner;
    }


    function getcommissionedVotes(address addr,uint campaignId)public view override returns (uint){
      return  commissionedVote[addr][campaignId];
    }

    function getDelegateVote(uint campaignId) external view override returns(uint){
        return everyVoteDelegateAmount[campaignId];
    }


    function subcommissionedVotes(address addr,uint campaignId,uint amount) external override{
      require(commissionedVote[addr][campaignId]>=amount,"Insufficient votes");
      commissionedVote[addr][campaignId]=commissionedVote[addr][campaignId]-amount;
    }



    function balanceOf(address addr) public view override returns(uint){
      return takenByAddr[addr]>0 ? 1 : 0;
    }


    function totalSupply() public view override returns(uint){
      return voteArray.length;
    }


     function approve(address to, uint256 tokenId) public  override {
      require(true, "Authorization is not supported");
    }


    function transfer(address from, address to, uint256 tokenId) public override {
     require(true,"Not at least transfer");
    }


     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override  {
        transfer(from,to,tokenId);
    }


    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
       safeTransferFrom(from,to,tokenId, "");
    }


    function setApprovalForAll(address operator, bool approved) public virtual override {
      require(true, "Authorization is not supported");
    }


    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
      require(true, "No authorization is pending");
    }


    function getApproved(uint256 tokenId) public view virtual override returns (address) {
      require(true, "No authorization is pending");
    }


   function  setPriorVotes (address[] memory addrArray,uint [] memory ratioArray)  override public{
        delete oracleVoteArray;
        require(addrArray.length==ratioArray.length,"The array length is inconsistent");
        for(uint i=0;i<addrArray.length;i++){
          for(uint j = 0;j< ratioArray.length; j++){
              if(i==j){
                  OracleVote memory oracleVote = OracleVote({
                     contractAddr: addrArray[i],
                     ratioFactor: ratioArray[j]
                  });
                oracleVoteArray.push(oracleVote);
            }
         }
     }

   }


   function  getVoteNum(address account, uint blockNumber) public view returns (uint num) {
     for(uint i=0;i<oracleVoteArray.length;i++){
       IVoteOracle RbVoteOracle = IVoteOracle(oracleVoteArray[i].contractAddr);
       num+=RbVoteOracle.getPriorVotes(account,blockNumber)*oracleVoteArray[i].ratioFactor;
     }
   }
}
