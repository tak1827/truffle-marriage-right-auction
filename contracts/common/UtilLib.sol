pragma solidity ^0.4.24;


library UtilLib {
    
    function hasUintArrayUintVal(uint[] _ary, uint _val) internal pure returns(bool) {
        for (uint i = 0; i < _ary.length; i++) {
            if (_ary[i] == _val) return true;
        }
        return false;
    }
    
    
}