#define _CRT_SECURE_NO_WARNINGS
#define _WINSOCK_DEPRECATED_NO_WARNINGS 
#pragma comment(lib, "ws2_32")
#include <winsock2.h>
#include <winsock.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include<string.h>
#include <time.h>

#define SERVERIP   "127.0.0.1"
#define SERVERPORT 3658
//#define BUFSIZE    1024

#pragma pack()
typedef struct data {
    float latitude, longtitude;
    int id;
    int batt_charge;
	char time[50];
}data;
#pragma pack()


// ���� �Լ� ���� ��� �� ����
void err_quit(char* msg)
{
    LPVOID lpMsgBuf;
    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
        NULL, WSAGetLastError(),
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR)&lpMsgBuf, 0, NULL);
    MessageBox(NULL, (LPCTSTR)lpMsgBuf, msg, MB_ICONERROR);
    LocalFree(lpMsgBuf);
    exit(1);
}

// ���� �Լ� ���� ���
void err_display(char* msg)
{
    LPVOID lpMsgBuf;
    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
        NULL, WSAGetLastError(),
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR)&lpMsgBuf, 0, NULL);
    printf("[%s] %s", msg, (char*)lpMsgBuf);
    LocalFree(lpMsgBuf);
}


// ����� ���� ������ ���� �Լ�
int recvn(SOCKET s, char* buf, int len, int flags)
{
    int received;
    char* ptr = buf;
    int left = len;

    while (left > 0) {
        received = recv(s, ptr, left, flags);
        if (received == SOCKET_ERROR)
            return SOCKET_ERROR;
        else if (received == 0)
            break;
        left -= received;  //���� ���ڼ� üũ
        ptr += received; //���� �����ּ� üũ
    }

    return (len - left);
}

int main(int argc, char* argv[])
{
	int retval;


	// ���� �ʱ�ȭ
	WSADATA wsa;
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
		return 1;

	// socket()
	SOCKET sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET)
		err_quit("socket()");

	// ���� �ɼ�

		//�ֱ������� ����Ǿ��ִ��� Ȯ��
	BOOL bEnable = TRUE;
	retval = setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, (char*)& bEnable, sizeof(bEnable));
	if (retval == SOCKET_ERROR)
		err_quit("setsocketopt( SO_KEEPALIVE)");

	//���ϼ۽� ���ۿ� ������ �����Ͱ� ���� ��� closesocket()�Լ��� ���� �����ð� ����
	LINGER optval;
	optval.l_onoff = 1;
	optval.l_linger = 10;
	if (setsockopt(sock, SOL_SOCKET, SO_LINGER, (char*)& optval, sizeof(optval)) == SOCKET_ERROR) {
		err_quit("setsocketopt( SO_LINGER)");
	}




	// connect()
	SOCKADDR_IN serveraddr;
	ZeroMemory(&serveraddr, sizeof(serveraddr));
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_addr.s_addr = inet_addr(SERVERIP);
	serveraddr.sin_port = htons(SERVERPORT);
	retval = connect(sock, (SOCKADDR*)& serveraddr, sizeof(serveraddr));
	if (retval == SOCKET_ERROR) err_quit("connect()");



	// ������ ��ſ� ����� ����
   /* typedef struct data {
		float latitude, longtitude;
		int id;
		int batt_charge;
	}data;*/
	
	

  /*  location* recvloc;
    battery* recvbat;*/

    // ������ ������ ���
    while (1) {
        // ������ �Է�
        printf("\n[������ ����] \n");
        // ������ ��ſ� ����� ����
        //char buf[BUFSIZE] = { 0 };


		data dt = { 128, 35, 26, 20 };


        if (sizeof(dt)== 0) {
            fprintf(stderr, "loss of data");
            break;
        }
           
    

        // ������ ������
         retval= send(sock, (const char*)&dt, sizeof(data), 0);
        if (retval == SOCKET_ERROR) {
            err_display("send()");
            break;
        }
		Sleep(5000);
        printf("[TCP Ŭ���̾�Ʈ] %d����Ʈ�� ���½��ϴ�.\n", retval);

        // ������ �ޱ�
        retval = recvn(sock, (const char*)&dt, retval, 0);
        if (retval == SOCKET_ERROR) {
            err_display("recv()");
            break;
        }
        else if (retval == 0)
            break;

        // ���� ������ ���
        printf("[TCP Ŭ���̾�Ʈ] %d����Ʈ�� �޾ҽ��ϴ�.\n", retval);
        printf("[���� ������] => latitude : %f  , lontitude : %f , id: %d ,batt_charge : %d\n", 
            dt.latitude, dt.longtitude, dt.id, dt.batt_charge );
    }

    // closesocket()
    closesocket(sock);

    // ���� ����
    WSACleanup();
    return 0;
}
