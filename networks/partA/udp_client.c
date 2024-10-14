// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <unistd.h>
// #include <arpa/inet.h>

// #define PORT 8080

// int main() {
//     int sockfd;
//     struct sockaddr_in serv_addr;
//     char buffer[1024];

//     sockfd = socket(AF_INET, SOCK_DGRAM, 0);
//     if (sockfd < 0) {
//         printf("Socket creation error\n");
//         return -1;
//     }

//     serv_addr.sin_family = AF_INET;
//     serv_addr.sin_port = htons(PORT);
//     serv_addr.sin_addr.s_addr = INADDR_ANY;

//     // Connect to server
//     sendto(sockfd, "Player connected", strlen("Player connected"), 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));

//     while (1) {
//         memset(buffer, 0, sizeof(buffer));
//         int addr_len = sizeof(serv_addr);
//         recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&serv_addr, &addr_len);
//         printf("%s", buffer);

//         // Check for game outcome
//         if (strstr(buffer, "wins") || strstr(buffer, "draw")) {
//             break;
//         }

//         if (strstr(buffer, "Your turn")) {
//             int row, col;
//             printf("Enter row and column (1, 2, or 3): ");
//             scanf("%d %d", &row, &col);
//             snprintf(buffer, sizeof(buffer), "%d %d", row-1, col-1);
//             sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
//         }
//     }

//     close(sockfd);
//     return 0;
// }

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080

int main() {
    int sockfd;
    struct sockaddr_in serv_addr;
    char buffer[1024];

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        printf("Socket creation error\n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);
    serv_addr.sin_addr.s_addr = INADDR_ANY;

    // Connect to server
    sendto(sockfd, "Player connected", strlen("Player connected"), 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));

    while (1) {
        memset(buffer, 0, sizeof(buffer));
        int addr_len = sizeof(serv_addr);
        recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&serv_addr, &addr_len);
        printf("%s", buffer);

        // Check for game outcome
        if (strcmp(buffer, "Thanks for playing! Goodbye!\n")==0) {
            break;
        }

        if (strstr(buffer, "Your turn")) {
            int row, col;
            printf("Enter row and column (1, 2, or 3): ");
            scanf("%d %d", &row, &col);
            snprintf(buffer, sizeof(buffer), "%d %d", row-1, col-1);
            sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
        }

        if (strstr(buffer, "play again?")) {
            char response[4];
            scanf("%s", response);
            sendto(sockfd, response, strlen(response), 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
        }
    }

    close(sockfd);
    return 0;
}
