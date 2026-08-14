#include <stdio.h>
#include <stdlib.h>

int arr[10] = {8, 12, 7, 1, 2, 10, 29, 3, 4, 9};

int search(int arr[], int n, int x){
    if(n == 1){
        return -1;
    }
    if(arr[n-1] == x){
        return 1;
    }

    return search(arr, n-1, x);
}

int main(){
    int n = sizeof(arr)/sizeof(arr[0]);
    int x;
    printf("ingrese el elemento a buscar: ");
    scanf("%d", &x);
    if(search(arr, n, x ) == 1){
        printf("Se encontro el numero");
    }else{
        printf("No se encontro el numero");
    }
    return 0;
}