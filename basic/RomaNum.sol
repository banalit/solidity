// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract RomaNum {
    
    
/**
4. 用 solidity 实现罗马数字转数整数
题目描述在 https://leetcode.cn/problems/integer-to-roman/description/
**/
    function romaToInt(string calldata roma) public pure returns (int) {
        // 定义罗马数字符号与对应值
        string[] memory symbols = getRomaArray();
        int[] memory values =  getIntArray();
        
        int result = 0;
        bytes memory romaBytes = bytes(roma);
        uint length = romaBytes.length;
        
        uint i = 0;
        while (i < length) {
            // 先尝试匹配双字符组合（如IV、IX等）
            if (i < length - 1) {
                string memory twoChar = string(abi.encodePacked(romaBytes[i], romaBytes[i+1]));
                int twoValue = getValue(twoChar, symbols, values);
                
                if (twoValue != 0) {
                    result += twoValue;
                    i += 2; // 跳过下一个字符
                    continue;
                }
            }
            
            // 匹配单字符
            string memory oneChar = string(abi.encodePacked(romaBytes[i]));
            result += getValue(oneChar, symbols, values);
            i += 1;
        }
        
        return result;
    }
    
    // 辅助函数：根据符号获取对应数值
    function getValue(string memory symbol, string[] memory symbols, int[] memory values) private pure returns (int) {
        for (uint i = 0; i < symbols.length; i++) {
            if (keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked(symbols[i]))) {
                return values[i];
            }
        }
        return 0; // 未找到对应符号
    }

/**
3.用 solidity 实现整数转罗马数字
题目描述在 https://leetcode.cn/problems/roman-to-integer/description/
**/
    function intToRoman(int num) public pure returns (string memory) {
        // 检查输入是否在有效范围内（1-3999）
        require(num >= 1 && num <= 3999, "Number must be between 1 and 3999");
        // 构建结果字符串
        string memory result = "";
        string[] memory symbols = getRomaArray();
        int[] memory values = getIntArray();
        
        // 贪心算法：从最大的数值开始处理
        for (uint i = 0; i < values.length; i++) {
            // 当当前数值小于等于剩余数值时，添加对应符号并减去该数值
            while (num >= values[i]) {
                result = string(abi.encodePacked(result, symbols[i]));
                num -= values[i];
            }
            // 数值处理完成，退出循环
            if (num == 0) {
                break;
            }
        }
        
        return result;
    }

    // 测试函数
    function test() public pure returns (string memory) {
        return intToRoman(1994); // 返回 "MCMXCIV"
    }

    function getIntArray() internal pure returns (int[] memory){
        // 定义罗马数字对应的数值和符号
        int[]memory values = new int[](13);
        values[0] = 1000;
        values[1] = 900;
        values[2] = 500;
        values[3] = 400;
        values[4] = 100;
        values[5] = 90;
        values[6] = 50;
        values[7] = 40;
        values[8] = 10;
        values[9] = 9;
        values[10] = 5;
        values[11] = 4;
        values[12] = 1;
        return values;
    }

    function getRomaArray() internal pure returns (string[]memory) {
        string[]memory symbols = new string[](13);
        symbols[0] = "M";
        symbols[1] = "CM";
        symbols[2] = "D";
        symbols[3] = "CD";
        symbols[4] = "C";
        symbols[5] = "XC";
        symbols[6] = "L";
        symbols[7] = "XL";
        symbols[8] = "X";
        symbols[9] = "IX";
        symbols[10] = "V";
        symbols[11] = "IV";
        symbols[12] = "I";
        return symbols;
    }
}
    