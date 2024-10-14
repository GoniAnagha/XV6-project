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

void receive_data(int sockfd, struct sockaddr_in *cliaddr, int *turn) {
    int total_chunks;
    socklen_t cli_len = sizeof(*cliaddr);
    recvfrom(sockfd, &total_chunks, sizeof(int), 0, (struct sockaddr *) cliaddr, &cli_len);

    for (int i = 0; i < total_chunks; i++) {
        chunk_t chunk;
        cli_len = sizeof(*cliaddr);
        recvfrom(sockfd, &chunk, sizeof(chunk_t), 0, (struct sockaddr *) cliaddr, &cli_len);
        printf("Received chunk %d: %s\n", chunk.sequence_number, chunk.data);

        if (strncmp(chunk.data, "bye", 3) == 0) {
            printf("Client said bye. Ending...\n");
            exit(0);
        }

        // Send ACK back to client
        chunk_t ack;
        ack.sequence_number = chunk.sequence_number;
        strncpy(ack.data, "ACK", 3);
        sendto(sockfd, &ack, sizeof(chunk_t), 0, (struct sockaddr *) cliaddr, cli_len);
    }

    (*turn)++;  // Change turn after receiving data
}

void send_response(int sockfd, struct sockaddr_in *cliaddr, int *turn) {
    char response[CHUNK_SIZE];
    printf("Enter response: ");
    fgets(response, CHUNK_SIZE, stdin);
    response[strlen(response) - 1] = '\0';  // Remove newline

    int total_chunks = (strlen(response) + CHUNK_SIZE - 1) / CHUNK_SIZE;
    socklen_t cli_len = sizeof(*cliaddr);
    sendto(sockfd, &total_chunks, sizeof(int), 0, (struct sockaddr *) cliaddr, cli_len);

    for (int i = 0; i < total_chunks; i++) {
        char chunk_data[CHUNK_SIZE];
        strncpy(chunk_data, response + i * CHUNK_SIZE, CHUNK_SIZE);
        chunk_t chunk;
        chunk.sequence_number = i + 1;
        strncpy(chunk.data, chunk_data, CHUNK_SIZE);
        sendto(sockfd, &chunk, sizeof(chunk_t), 0, (struct sockaddr *) cliaddr, cli_len);
    }

    if (strncmp(response, "bye", 3) == 0) {
        printf("Server said bye. Ending...\n");
        exit(0);
    }

    (*turn)++;  // Change turn after sending response
}

int main() {
    int sockfd, turn = 0;  // 0 = client turn, 1 = server turn
    struct sockaddr_in servaddr, cliaddr;

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("socket creation failed");
        exit(1);
    }

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
    servaddr.sin_port = htons(8080);

    bind(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));

    while (1) {
        if (turn % 2 == 0) {
            printf("Waiting for client's message...\n");
            receive_data(sockfd, &cliaddr, &turn);
        } else {
            send_response(sockfd, &cliaddr, &turn);
        }
    }

    close(sockfd);
    return 0;
}
