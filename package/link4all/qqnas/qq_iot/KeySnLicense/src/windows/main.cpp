#include "../SSLKernelItem.h"
#include <tchar.h>

int _tmain(int argc, _TCHAR* argv[])
{
	CreateECDSAKey("./");
	ECDSASignBufferBase16ToLicenceFile("./ec_key.pem", "carol-0000000001", strlen("carol-0000000001"), "./license.txt");
	int nRet = ECDSAVerifyBase16LicenceFile("./public.pem", "../../../guid.txt", "./license.txt");
	if(nRet == 1)
	{
		printf("��֤�ɹ�\n");
	}
	else 
	{
		printf("��֤ʧ�ܣ�������:[%d]\n", nRet);
	}
	getchar();
	return 0;
}