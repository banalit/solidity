// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 6.二分查找 (Binary Search)
题目描述：在一个有序数组中查找目标值。
返回值：目标值在数组中的索引，若不存在则返回 -1
**/
contract BinarySearch {
    /**
     * @dev 二分查找实现
     * @param arr 已排序的整数数组（假设为非递减排序）
     * @param target 要查找的目标值
     * @return 目标值的索引，未找到则返回 -1
     */
    function search(int[] memory arr, int target) public pure returns (int) {
        uint left = 0;
        uint right = arr.length - 1;
        while (left<=right) {
            uint mid = left+(right-left)/2;
            if (arr[mid]==target) {
                return int(mid);
            } else if(arr[mid]<target) {
                left = mid+1;
            } else {
                right = mid-1;
            }
        }
        return -1;
    }
}
