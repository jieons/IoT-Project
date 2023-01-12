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


// ���� �Լ� ���� ��� �� ����
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

// ���� �Լ� ���� ���
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
	data* dt; //����ü ����
	dt = (data*)buf; // ���ڿ��� �� ������ ����ü��

	if (temp == false) { //db ����
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

/*else { //���� ���� ��
		fprintf(stderr, "���� ���� : %s\n", mysql_error(cons));
	}*/
}

// Ŭ���̾�Ʈ�� ������ ���
DWORD WINAPI ProcessClient(LPVOID arg)
{
	SOCKET client_sock = (SOCKET)arg;
	int retval;
	SOCKADDR_IN clientaddr;
	int addrlen;
	//char buf[BUFSIZE + 1];

	// Ŭ���̾�Ʈ ���� ���
	addrlen = sizeof(clientaddr);
	getpeername(client_sock, (SOCKADDR*)& clientaddr, &addrlen);
	data* dt;
	//WaitForSingleObject(hMutex, INFINITE);
	while (1) {
		// ������ �ޱ�
		retval = recv(client_sock, buf, BUFSIZE, 0);
		if (retval == SOCKET_ERROR) {
			err_display("recv()");
			break;
		}
		else if (retval == 0)
			break;
		dt = (data*)buf; //���ڿ��� ������ ����ü�� �ٲ۰�

		// ���� ������ ���
		buf[retval] = '\0';
		printf("[TCP/ %s: \n%d] latitude : %f , longtitude : %f ,id : %d ,batt_charge : %d, time : %s \n", inet_ntoa(clientaddr.sin_addr),
			ntohs(clientaddr.sin_port), dt->latitude, dt->longtitude, dt->id, dt->batt_charge, dt->time);


		// ������ ������
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
	printf("[TCP ����] Ŭ���̾�Ʈ ����: IP �ּ�=%s, ��Ʈ ��ȣ=%d\n",
		inet_ntoa(clientaddr.sin_addr), ntohs(clientaddr.sin_port));

	return 0;
}





int main(int argc, char* argv[])
{
	int retval;

	cons = mysql_init(NULL);            //MYSQL ���� �ʱ�ȭ

	// ���� �ʱ�ȭ
	WSADATA wsa;
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
		return 1;

	//���ؽ�
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

	// ������ ��ſ� ����� ����
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
		// ������ Ŭ���̾�Ʈ ���� ���
		printf("\n[TCP ����] Ŭ���̾�Ʈ ����: IP �ּ�=%s, ��Ʈ ��ȣ=%d\n",
			inet_ntoa(clientaddr.sin_addr), ntohs(clientaddr.sin_port));

		//ReleaseMutex(hMutex);

		// ������ ����
		hThread = CreateThread(NULL, 0, ProcessClient,
			(LPVOID)client_sock, 0, NULL);
		if (hThread == NULL) { closesocket(client_sock); }
		else { CloseHandle(hThread); }

		//sql(MYSQLIP, cons);
	}


	// closesocket()
	closesocket(listen_sock);
	mysql_close(cons);

	// ���� ����
	WSACleanup();
	return 0;
}