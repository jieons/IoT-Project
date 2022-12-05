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


// 소켓 함수 오류 출력 후 종료
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

// 소켓 함수 오류 출력
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


// 사용자 정의 데이터 수신 함수
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
        left -= received;  //남은 글자수 체크
        ptr += received; //남은 버퍼주소 체크
    }

    return (len - left);
}

int main(int argc, char* argv[])
{
	int retval;


	// 윈속 초기화
	WSADATA wsa;
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
		return 1;

	// socket()
	SOCKET sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET)
		err_quit("socket()");

	// 소켓 옵션

		//주기적으로 연결되어있는지 확인
	BOOL bEnable = TRUE;
	retval = setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, (char*)& bEnable, sizeof(bEnable));
	if (retval == SOCKET_ERROR)
		err_quit("setsocketopt( SO_KEEPALIVE)");

	//소켓송신 버퍼에 미전송 데이터가 있을 경우 closesocket()함수의 리턴 지연시간 설정
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



	// 데이터 통신에 사용할 변수
   /* typedef struct data {
		float latitude, longtitude;
		int id;
		int batt_charge;
	}data;*/
	
	

  /*  location* recvloc;
    battery* recvbat;*/

    // 서버와 데이터 통신
    while (1) {
        // 데이터 입력
        printf("\n[데이터 전송] \n");
        // 데이터 통신에 사용할 변수
        //char buf[BUFSIZE] = { 0 };


		data dt = { 128, 35, 26, 20 };


        if (sizeof(dt)== 0) {
            fprintf(stderr, "loss of data");
            break;
        }
           
    

        // 데이터 보내기
         retval= send(sock, (const char*)&dt, sizeof(data), 0);
        if (retval == SOCKET_ERROR) {
            err_display("send()");
            break;
        }
		Sleep(5000);
        printf("[TCP 클라이언트] %d바이트를 보냈습니다.\n", retval);

        // 데이터 받기
        retval = recvn(sock, (const char*)&dt, retval, 0);
        if (retval == SOCKET_ERROR) {
            err_display("recv()");
            break;
        }
        else if (retval == 0)
            break;

        // 받은 데이터 출력
        printf("[TCP 클라이언트] %d바이트를 받았습니다.\n", retval);
        printf("[보낸 데이터] => latitude : %f  , lontitude : %f , id: %d ,batt_charge : %d\n", 
            dt.latitude, dt.longtitude, dt.id, dt.batt_charge );
    }

    // closesocket()
    closesocket(sock);

    // 윈속 종료
    WSACleanup();
    return 0;
}
