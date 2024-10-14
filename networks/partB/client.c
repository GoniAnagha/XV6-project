#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>

#define CHUNK_SIZE 1024
#define TIMEOUT 0.1

typedef struct {
    int sequence_number;
    char data[CHUNK_SIZE];
} chunk_t;

void send_data(int sockfd, struct sockaddr_in *servaddr, int *turn) {
    char data[CHUNK_SIZE];
    printf("Enter message: ");
    fgets(data, CHUNK_SIZE, stdin);
    data[strlen(data) - 1] = '\0';  // Remove newline

    int total_chunks = (strlen(data) + CHUNK_SIZE - 1) / CHUNK_SIZE;
    socklen_t serv_len = sizeof(*servaddr);
    sendto(sockfd, &total_chunks, sizeof(int), 0, (struct sockaddr *) servaddr, serv_len);

    for (int i = 0; i < total_chunks; i++) {
        char chunk_data[CHUNK_SIZE];
        strncpy(chunk_data, data + i * CHUNK_SIZE, CHUNK_SIZE);
        chunk_t chunk;
        chunk.sequence_number = i + 1;
        strncpy(chunk.data, chunk_data, CHUNK_SIZE);
        sendto(sockfd, &chunk, sizeof(chunk_t), 0, (struct sockaddr *) servaddr, serv_len);
    }

    if (strncmp(data, "bye", 3) == 0) {
        printf("Client said bye. Ending...\n");
        exit(0);
    }

    (*turn)++;  // Change turn after sending data
}

void receive_response(int sockfd, struct sockaddr_in *servaddr, int *turn) {
    int total_chunks;
    socklen_t serv_len = sizeof(*servaddr);
    recvfrom(sockfd, &total_chunks, sizeof(int), 0, (struct sockaddr *) servaddr, &serv_len);

    for (int i = 0; i < total_chunks; i++) {
        chunk_t chunk;
        serv_len = sizeof(*servaddr);
        recvfrom(sockfd, &chunk, sizeof(chunk_t), 0, (struct sockaddr *) servaddr, &serv_len);
        printf("Received chunk %d: %s\n", chunk.sequence_number, chunk.data);

        if (strncmp(chunk.data, "bye", 3) == 0) {
            printf("Server said bye. Ending...\n");
            exit(0);
        }
    }

    (*turn)++;  // Change turn after receiving response
}

int main() {
    int sockfd, turn = 0;  // 0 = client turn, 1 = server turn
    struct sockaddr_in servaddr;

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("socket creation failed");
        exit(1);
    }

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
    servaddr.sin_port = htons(8080);

    while (1) {
        if (turn % 2 == 0) {
            send_data(sockfd, &servaddr, &turn);
        } else {
            printf("Waiting for server's response...\n");
            receive_response(sockfd, &servaddr, &turn);
        }
    }

    close(sockfd);
    return 0;
}
