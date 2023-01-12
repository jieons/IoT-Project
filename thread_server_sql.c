#define _CRT_SECURE_NO_WARNINGS
#define _WINSOCK_DEPRECATED_NO_WARNINGS 
#pragma comment(lib, "ws2_32")
#include <winsock2.h>
#include <winsock.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>



#define _CRT_MONSTDC_N0_DEPRECATE
#include <string.h>
#include <mysql.h>
#pragma comment (lib, "libmysql.lib")

#define MYSQLUSER "root"         
#define MYSQLPASSWORD "wldjs1216"      
#define MYSQLIP "localhost"   


#define SERVERPORT 3658
#define BUFSIZE    1024

//HANDLE  hMutex;
MYSQL* cons;
bool temp = false;

#pragma pack()
typedef struct data {
	float latitude, longtitude;
	int id;
	int batt_charge;
	char time[50];
}data;

char buf[BUFSIZE + 1];

#pragma pack()


// 소켓 함수 오류 출력 후 종료
void err_quit(char* msg)
{
	LPVOID lpMsgBuf;
	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
		NULL, WSAGetLastError(),
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR)& lpMsgBuf, 0, NULL);
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
		(LPTSTR)& lpMsgBuf, 0, NULL);
	printf("[%s] %s", msg, (char*)lpMsgBuf);
	LocalFree(lpMsgBuf);
}


void sql(char mysqlip[], MYSQL* cons) {
	data* dt; //구조체 생성
	dt = (data*)buf; // 문자열로 온 정보를 구조체로

	if (temp == false) { //db 연결
		mysql_real_connect(cons, mysqlip, MYSQLUSER, MYSQLPASSWORD, "gps_test", 0, NULL, 0) == NULL;
		temp = true;
	}

	//mysql_query(cons, "create database if not exists gps");
	/*mysql_query(cons,
			  "create table if not exists info (id int not null, latitude float, longtitude float, batt_charge int");*/
	int id = dt->id;
	float lat = dt->latitude;
	float lon = dt->longtitude;
	int batt = dt->batt_charge;

	char query[1000];
	//if (lat > 0 && lon > 0) {
		sprintf(query, "insert into gps_test.info values(%d, %f, %f, %s, %d)", id, lat, lon, dt->time, batt);
	//}
	temp = true;

	int stat = mysql_query(cons, query);
	if (stat != 0) {
		fprintf(stderr, "%s\n", mysql_error(cons));
		return 1;
	}
	//mysql_close(cons);

/*else { //연결 실패 시
		fprintf(stderr, "연결 오류 : %s\n", mysql_error(cons));
	}*/
}

// 클라이언트와 데이터 통신
DWORD WINAPI ProcessClient(LPVOID arg)
{
	SOCKET client_sock = (SOCKET)arg;
	int retval;
	SOCKADDR_IN clientaddr;
	int addrlen;
	//char buf[BUFSIZE + 1];

	// 클라이언트 정보 얻기
	addrlen = sizeof(clientaddr);
	getpeername(client_sock, (SOCKADDR*)& clientaddr, &addrlen);
	data* dt;
	//WaitForSingleObject(hMutex, INFINITE);
	while (1) {
		// 데이터 받기
		retval = recv(client_sock, buf, BUFSIZE, 0);
		if (retval == SOCKET_ERROR) {
			err_display("recv()");
			break;
		}
		else if (retval == 0)
			break;
		dt = (data*)buf; //문자열의 내용을 구조체로 바꾼것

		// 받은 데이터 출력
		buf[retval] = '\0';
		printf("[TCP/ %s: \n%d] latitude : %f , longtitude : %f ,id : %d ,batt_charge : %d, time : %s \n", inet_ntoa(clientaddr.sin_addr),
			ntohs(clientaddr.sin_port), dt->latitude, dt->longtitude, dt->id, dt->batt_charge, dt->time);


		// 데이터 보내기
		retval = send(client_sock, buf, retval, 0);
		if (retval == SOCKET_ERROR) {
			err_display("send()");
			break;
		}
		sql(MYSQLIP, cons);
	}
	//ReleaseMutex(hMutex);
	// closesocket()
	closesocket(client_sock);
	printf("[TCP 서버] 클라이언트 종료: IP 주소=%s, 포트 번호=%d\n",
		inet_ntoa(clientaddr.sin_addr), ntohs(clientaddr.sin_port));

	return 0;
}





int main(int argc, char* argv[])
{
	int retval;

	cons = mysql_init(NULL);            //MYSQL 연결 초기화

	// 윈속 초기화
	WSADATA wsa;
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
		return 1;

	//뮤텍스
	//hMutex = CreateMutex(NULL, FALSE, NULL);
	// socket()
	SOCKET listen_sock = socket(AF_INET, SOCK_STREAM, 0);
	if (listen_sock == INVALID_SOCKET) err_quit("socket()");


	// bind()
	SOCKADDR_IN serveraddr;
	ZeroMemory(&serveraddr, sizeof(serveraddr));
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
	serveraddr.sin_port = htons(SERVERPORT);
	retval = bind(listen_sock, (SOCKADDR*)& serveraddr, sizeof(serveraddr));
	if (retval == SOCKET_ERROR) err_quit("bind()");

	// listen()
	retval = listen(listen_sock, SOMAXCONN);
	if (retval == SOCKET_ERROR) err_quit("listen()");

	// 데이터 통신에 사용할 변수
	SOCKET client_sock;
	SOCKADDR_IN clientaddr;
	int addrlen;
	HANDLE hThread;



	while (1) {
		// accept()
		addrlen = sizeof(clientaddr);
		client_sock = accept(listen_sock, (SOCKADDR*)& clientaddr, &addrlen);
		if (client_sock == INVALID_SOCKET) {
			err_display("accept()");
			break;
		}

		//WaitForSingleObject(hMutex, INFINITE);
		// 접속한 클라이언트 정보 출력
		printf("\n[TCP 서버] 클라이언트 접속: IP 주소=%s, 포트 번호=%d\n",
			inet_ntoa(clientaddr.sin_addr), ntohs(clientaddr.sin_port));

		//ReleaseMutex(hMutex);

		// 스레드 생성
		hThread = CreateThread(NULL, 0, ProcessClient,
			(LPVOID)client_sock, 0, NULL);
		if (hThread == NULL) { closesocket(client_sock); }
		else { CloseHandle(hThread); }

		//sql(MYSQLIP, cons);
	}


	// closesocket()
	closesocket(listen_sock);
	mysql_close(cons);

	// 윈속 종료
	WSACleanup();
	return 0;
}