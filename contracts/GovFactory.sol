pragma experimental ABIEncoderV2;
pragma solidity ^0.5.16;
import './GovernorAlpha.sol';
contract GovFactory {
    PublicStruct.govInfo[] public govs;
    function newGov(address timelock_, address comp_, address guardian_,string memory name_, string memory logo_) public returns(PublicStruct.govInfo memory) {
        GovernorAlpha gov = new GovernorAlpha(timelock_,comp_,guardian_);
        PublicStruct.govInfo memory govInfo = PublicStruct.govInfo({
            govAddress:address(gov),
            name:name_,
            logo:logo_
        });
        govs.push(govInfo);
        return govInfo;
    }
}







