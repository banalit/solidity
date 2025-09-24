// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 5.合并两个有序数组 (Merge Sorted Array)
题目描述：将两个有序数组合并为一个有序数组。
**/
contract MergeSortedArray {
    
    function merge(int[] memory nums1, int[] memory nums2) public pure returns (int[] memory) {
        uint m = nums1.length;
        uint n = nums2.length;
        int[] memory merged = new int[](m + n);
        uint i = 0;
        uint j = 0;
        uint m_idx = 0;
        
        while (i < m && j<n) {
            if (nums1[i] < nums2[j]) {
                merged[m_idx] = nums1[i];
                i++;
            } else {
                merged[m_idx] = nums2[j];
                j++;
            }
            m_idx++;
        }
        
        while (i < m) {
            merged[m_idx] = nums1[i];
            i++;
            m_idx++;
        }
        
        while (j < n) {
            merged[m_idx] = nums2[j];
            j++;
            m_idx++;
        }
        return merged;
    }
}