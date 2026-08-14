#include <stdio.h>
#include <stdlib.h>

int arr[10] = {8, 12, 7, 1, 2, 10, 29, 3, 4, 9};

int max(int arr[], int n){
    if(n == 1){
        return arr[0];
    }

    int count = max(arr, n - 1);

    if(arr[n-1] > count ){
        return arr[n-1];
    }else{
        return count;
    }
}

int main(){
    int n = sizeof(arr)/sizeof(arr[0]);

    printf("El valor maximo de la lista es: %d", max(arr, n));
    return 0;
}