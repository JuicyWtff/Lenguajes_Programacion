#include <stdio.h>
#include <stdlib.h>


typedef struct Node{
    int data;
    struct Node* next;
}Node;


Node* createNode(int value){
    Node *new = (Node*)malloc(sizeof(Node));
    if(new == NULL){
        printf("Error al asignar memoria\n");
        exit(1);
    }
    new->data = value;
    new->next = NULL;
    return new;
}

void insertAtBegin(Node **headRef, int value){
    Node *new = createNode(value);
    new->next = *headRef;
    *headRef = new;
}

void insertAtEnd(Node **headRef, int value){
    Node *new = createNode(value);

    if(*headRef == NULL){
        *headRef = new;
        return;
    }

    Node *temp = *headRef;
    while(temp->next != NULL){
        temp = temp->next;
    }
    temp->next = new;
}

void printList(Node *headRef){
    Node *temp = headRef;
    while(temp != NULL){
        printf("%d -> ", temp->data);
        temp = temp->next;
    }
    printf("NULL\n");
}

void cleanList(Node *headRef){
    Node *actual = headRef;
    Node *temp;

    while(actual != NULL){
        temp = actual;
        actual = actual->next;
        free(temp);
    }
}

int sum(Node *headRef){
    Node *temp = headRef;
    int c = 0;
    while(temp != NULL){
        c = temp->data + c;
        temp = temp->next;
    }
    return c;
}

int sumRecursiva(Node *headRef){
    if(headRef == NULL ){
        return 0;
    }
    return headRef->data + sumRecursiva(headRef->next);
}

int main(){
    Node *list = NULL;

    insertAtEnd(&list, 8);
    insertAtEnd(&list, 9);
    insertAtBegin(&list, 10);

    printList(list);

    //printf("La suma de los datos de la lista es:%d\n", sum(list));
    printf("La suma de los datos de la lista es:%d\n", sumRecursiva(list));

    cleanList(list);
    list = NULL;

    return 0;
}