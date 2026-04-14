#include <stdio.h>

struct Node {
    int val;
    struct Node *left;
    struct Node *right;
};

struct Node* makenode(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);
int getAtMost(int val, struct Node* root);

int main() 
{
    struct Node* root = NULL;

    root = insert(root, 50);
    root = insert(root, 30);
    root = insert(root, 70);
    root = insert(root, 20);
    root = insert(root, 40);
    root = insert(root, 60);
    root = insert(root, 80);

    struct Node* found = get(root, 40);
    if (found != NULL) printf("found %d\n", found->val);
    else printf("not found\n");

    found = get(root, 100);
    if (found != NULL) printf("found %d\n", found->val);
    else printf("not found\n");

    printf("%d\n", getAtMost(65, root));  //60
    printf("%d\n", getAtMost(25, root));  //20
    printf("%d\n", getAtMost(10, root));  //-1

    return 0;
}
