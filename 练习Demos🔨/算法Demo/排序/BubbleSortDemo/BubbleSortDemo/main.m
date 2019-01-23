//
//  main.m
//  BubbleSortDemo
//
//  Created by MichaelMao on 2019/1/22.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

#import <Foundation/Foundation.h>

void bubbleSort(void);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        bubbleSort();
    }
    return 0;
}


void bubbleSort(void){
    int i, j, t;
    int n = 5;
//    int a[5] = {12, 35, 99, 18, 76};
    int a[5] = {12, 18, 35, 76, 99};
    
    printf("排序之前的元素\n");

    for(i=0;i<n;i++) //输出结果
        printf("a[%d] = %d \n", i, a[i]);
    printf("\n");

    //冒泡排序的核心部分

    // 对所有元素进行遍历
    // n个数排序，只用进行n-1趟
    for(i=0; i<n-1; i++) {
        // 对指定的第i和第i+1个元素进行比较
        // j<n-i是因为，每次遍历后，都将目标元素放在最后，
        // 所以i为已经遍历完成的次数,n-i为剩下需要遍历的元素个数。
        for(j=0; j<n-i; j++) {
//            printf("a[%d] = %d ", j, a[j]);
//            printf("a[%d] = %d \n\n", j+1, a[j+1]);
            // 对指定的第i和第i+1个元素进行比较
            if(a[j] < a[j+1]){
                // 交换位置
                t = a[j];
                a[j] =a[j+1];
                a[j+1] = t;
            }
        }
    }
    printf("排序之后的元素\n");
    for(i=0;i<n;i++) //输出结果
    printf("a[%d] = %d \n", i, a[i]);
}
