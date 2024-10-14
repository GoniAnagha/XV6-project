// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <unistd.h>
// #include <arpa/inet.h>

// #define PORT 8080
// #define MAX_CLIENTS 2

// char board[3][3];
// int player_turn = 0;  // 0 for player 1, 1 for player 2

// void init_board() {
//     for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//             board[i][j] = ' ';
//         }
//     }
// }

// void print_board() {
//     printf("\n");
//     for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//             printf(" %c ", board[i][j]);
//             if (j < 2) printf("|");
//         }
//         if (i < 2) printf("\n---|---|---\n");
//     }
//     printf("\n");
// }

// void send_board(int sockfd, struct sockaddr_in *client_addrs) {
//     char buffer[1024];
//     snprintf(buffer, sizeof(buffer),
//              "\n %c | %c | %c\n---|---|---\n %c | %c | %c\n---|---|---\n %c | %c | %c\n",
//              board[0][0], board[0][1], board[0][2],
//              board[1][0], board[1][1], board[1][2],
//              board[2][0], board[2][1], board[2][2]);
//     for (int i = 0; i < MAX_CLIENTS; i++) {
//         sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&client_addrs[i], sizeof(client_addrs[i]));
//     }
// }

// int check_winner() {
//     for (int i = 0; i < 3; i++) {
//         if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != ' ')
//             return (board[i][0] == 'X') ? 1 : 2;
//         if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != ' ')
//             return (board[0][i] == 'X') ? 1 : 2;
//     }
//     if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != ' ')
//         return (board[0][0] == 'X') ? 1 : 2;
//     if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != ' ')
//         return (board[0][2] == 'X') ? 1 : 2;
//     return 0;  // No winner
// }

// int check_draw() {
//     for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//             if (board[i][j] == ' ') return 0;
//         }
//     }
//     return 1;  // Draw
// }

// void update_board(int row, int col, char mark) {
//     board[row][col] = mark;
// }

// int main() {
//     int sockfd;
//     struct sockaddr_in server_addr, client_addrs[MAX_CLIENTS];
//     socklen_t addr_len = sizeof(struct sockaddr_in);
//     char buffer[1024];

//     init_board();
//     sockfd = socket(AF_INET, SOCK_DGRAM, 0);
//     if (sockfd < 0) {
//         perror("Socket creation failed");
//         exit(EXIT_FAILURE);
//     }

//     memset(&server_addr, 0, sizeof(server_addr));
//     server_addr.sin_family = AF_INET;
//     server_addr.sin_addr.s_addr = INADDR_ANY;
//     server_addr.sin_port = htons(PORT);
    
//     bind(sockfd, (const struct sockaddr *)&server_addr, sizeof(server_addr));
    
//     printf("Waiting for players to connect...\n");
    
//     for (int i = 0; i < MAX_CLIENTS; i++) {
//         recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addrs[i], &addr_len);
//         printf("Player %d connected\n", i + 1);
//         if (i == 0) {
//             sendto(sockfd, "You are Player 1 (X).", strlen("You are Player 1 (X)."), 0, (struct sockaddr *)&client_addrs[i], addr_len);
//         } else {
//             sendto(sockfd, "You are Player 2 (O).", strlen("You are Player 2 (O)."), 0, (struct sockaddr *)&client_addrs[i], addr_len);
//         }
//     }
    
//     send_board(sockfd, client_addrs);
//     int row, col, winner;

//     while (1) {
//         if (player_turn == 0) {
//             sendto(sockfd, "Your turn (Player 1 - X):", strlen("Your turn (Player 1 - X):"), 0, (struct sockaddr *)&client_addrs[0], addr_len);
//             recvfrom(sockfd, buffer, sizeof(buffer), 0, NULL, NULL);
//             sscanf(buffer, "%d %d", &row, &col);
//             if (row >= 0 && row < 3 && col >= 0 && col < 3 && board[row][col] == ' ') {
//                 update_board(row, col, 'X');
//                 player_turn = 1;
//             } else {
//                 sendto(sockfd, "Invalid move. Try again.", strlen("Invalid move. Try again."), 0, (struct sockaddr *)&client_addrs[0], addr_len);
//                 continue;
//             }
//         } else {
//             sendto(sockfd, "Your turn (Player 2 - O):", strlen("Your turn (Player 2 - O):"), 0, (struct sockaddr *)&client_addrs[1], addr_len);
//             recvfrom(sockfd, buffer, sizeof(buffer), 0, NULL, NULL);
//             sscanf(buffer, "%d %d", &row, &col);
//             if (row >= 0 && row < 3 && col >= 0 && col < 3 && board[row][col] == ' ') {
//                 update_board(row, col, 'O');
//                 player_turn = 0;
//             } else {
//                 sendto(sockfd, "Invalid move. Try again.", strlen("Invalid move. Try again."), 0, (struct sockaddr *)&client_addrs[1], addr_len);
//                 continue;
//             }
//         }

//         send_board(sockfd, client_addrs);
//         winner = check_winner();
//         if (winner) {
//             snprintf(buffer, sizeof(buffer), "Player %d wins!\n", winner);
//             for (int i = 0; i < MAX_CLIENTS; i++) {
//                 sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&client_addrs[i], addr_len);
//             }
//             break;
//         }

//         if (check_draw()) {
//             sendto(sockfd, "It's a draw!\n", strlen("It's a draw!\n"), 0, (struct sockaddr *)&client_addrs[0], addr_len);
//             sendto(sockfd, "It's a draw!\n", strlen("It's a draw!\n"), 0, (struct sockaddr *)&client_addrs[1], addr_len);
//             break;
//         }
//     }

//     // Cleanup
//     close(sockfd);
//     return 0;
// }


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define MAX_CLIENTS 2

char board[3][3];
int player_turn = 0;  // 0 for player 1, 1 for player 2

void init_board() {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            board[i][j] = ' ';
        }
    }
}

void send_board(int sockfd, struct sockaddr_in *client_addrs) {
    char buffer[1024];
    snprintf(buffer, sizeof(buffer),
             "\n %c | %c | %c\n---|---|---\n %c | %c | %c\n---|---|---\n %c | %c | %c\n",
             board[0][0], board[0][1], board[0][2],
             board[1][0], board[1][1], board[1][2],
             board[2][0], board[2][1], board[2][2]);
    for (int i = 0; i < MAX_CLIENTS; i++) {
        sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&client_addrs[i], sizeof(client_addrs[i]));
    }
}

int check_winner() {
    for (int i = 0; i < 3; i++) {
        if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != ' ')
            return (board[i][0] == 'X') ? 1 : 2;
        if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != ' ')
            return (board[0][i] == 'X') ? 1 : 2;
    }
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != ' ')
        return (board[0][0] == 'X') ? 1 : 2;
    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != ' ')
        return (board[0][2] == 'X') ? 1 : 2;
    return 0;  // No winner
}

int check_draw() {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (board[i][j] == ' ') return 0;
        }
    }
    return 1;  // Draw
}

void update_board(int row, int col, char mark) {
    board[row][col] = mark;
}

int main() {
    int sockfd;
    struct sockaddr_in server_addr, client_addrs[MAX_CLIENTS];
    socklen_t addr_len = sizeof(struct sockaddr_in);
    char buffer[1024];

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);
    
    bind(sockfd, (const struct sockaddr *)&server_addr, sizeof(server_addr));
    
    printf("Waiting for players to connect...\n");
    
    for (int i = 0; i < MAX_CLIENTS; i++) {
        recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addrs[i], &addr_len);
        printf("Player %d connected\n", i + 1);
        sendto(sockfd, (i == 0) ? "You are Player 1 (X)." : "You are Player 2 (O).", 
               (i == 0) ? strlen("You are Player 1 (X).") : strlen("You are Player 2 (O)."), 
               0, (struct sockaddr *)&client_addrs[i], addr_len);
    }

    while (1) {
        init_board();
        player_turn = 0;
        int row, col;

        while (1) {
            send_board(sockfd, client_addrs);
            if (player_turn == 0) {
                sendto(sockfd, "Your turn (Player 1 - X):", strlen("Your turn (Player 1 - X):"), 0, (struct sockaddr *)&client_addrs[0], addr_len);
                recvfrom(sockfd, buffer, sizeof(buffer), 0, NULL, NULL);
                sscanf(buffer, "%d %d", &row, &col);
                if (row >= 0 && row < 3 && col >= 0 && col < 3 && board[row][col] == ' ') {
                    update_board(row, col, 'X');
                    player_turn = 1;
                } else {
                    sendto(sockfd, "Invalid move. Try again.", strlen("Invalid move. Try again."), 0, (struct sockaddr *)&client_addrs[0], addr_len);
                    continue;
                }
            } else {
                sendto(sockfd, "Your turn (Player 2 - O):", strlen("Your turn (Player 2 - O):"), 0, (struct sockaddr *)&client_addrs[1], addr_len);
                recvfrom(sockfd, buffer, sizeof(buffer), 0, NULL, NULL);
                sscanf(buffer, "%d %d", &row, &col);
                if (row >= 0 && row < 3 && col >= 0 && col < 3 && board[row][col] == ' ') {
                    update_board(row, col, 'O');
                    player_turn = 0;
                } else {
                    sendto(sockfd, "Invalid move. Try again.", strlen("Invalid move. Try again."), 0, (struct sockaddr *)&client_addrs[1], addr_len);
                    continue;
                }
            }

            int winner = check_winner();
            if (winner) {
                snprintf(buffer, sizeof(buffer), "Player %d wins!\n", winner);
                for (int i = 0; i < MAX_CLIENTS; i++) {
                    sendto(sockfd, buffer, strlen(buffer), 0, (struct sockaddr *)&client_addrs[i], addr_len);
                }
                break;
            }

            if (check_draw()) {
                sendto(sockfd, "It's a draw!\n", strlen("It's a draw!\n"), 0, (struct sockaddr *)&client_addrs[0], addr_len);
                sendto(sockfd, "It's a draw!\n", strlen("It's a draw!\n"), 0, (struct sockaddr *)&client_addrs[1], addr_len);
                break;
            }
        }

        // Ask if they want to play again
        char response[4];
        for (int i = 0; i < MAX_CLIENTS; i++) {
            sendto(sockfd, "Do you want to play again? (yes/no)", strlen("Do you want to play again? (yes/no)"), 0, (struct sockaddr *)&client_addrs[i], addr_len);
            recvfrom(sockfd, response, sizeof(response), 0, NULL, NULL);
            response[3] = '\0';  // Null terminate the response
        }

        if (strcmp(response, "yes") != 0) {
            for (int i = 0; i < MAX_CLIENTS; i++) {
                sendto(sockfd, "Thanks for playing! Goodbye!\n", strlen("Thanks for playing! Goodbye!\n"), 0, (struct sockaddr *)&client_addrs[i], addr_len);
            }
            break;
        }
    }

    close(sockfd);
    return 0;
}
