#pragma semicolon 1
#pragma newdecls required
#include <sdktools>

public Plugin myinfo = 
{
	name = "Map configs New",
	description = "Map specific configs execution with prefix support. KV version",
	author = "ღ λŌK0ЌЭŦ ღ ™",
	version = "1.2",
	url = ""
}

KeyValues kv;


public void OnPluginStart() 
{
	LoagKv();
	ExecuteMapSpecificConfigs();
}

public void OnAutoConfigsBuffered() 
{
	ExecuteMapSpecificConfigs();
}

public void OnMapEnd()
{
	LoagKv();
}

stock void ExecuteMapSpecificConfigs() 
{
	char iMap[128];
	GetCurrentMap(iMap, sizeof(iMap));

	if(iMap[0] == 'w' && iMap[1] == 'o')
	{
		char buff[3][128];
		ExplodeString(iMap, "/", buff, 3, sizeof(buff[]));
		iMap = buff[2];
	}

	char buffMapName[32], buffCmdName[64], buffCmdValue[32];

	kv.Rewind();
	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(buffMapName, sizeof(buffMapName));
			if(StrContains(iMap, buffMapName, false) != -1 && kv.GotoFirstSubKey(false))
			{	
				do
				{
					kv.GetSectionName(buffCmdName, sizeof(buffCmdName));
					kv.GetString(NULL_STRING, buffCmdValue, sizeof(buffCmdValue));

					ServerCommand("%s %s", buffCmdName, buffCmdValue);
				}
				while(kv.GotoNextKey(false));

				kv.Rewind();
				kv.JumpToKey(buffMapName);
			}
		}
		while(kv.GotoNextKey());
	} 
	
	delete kv;
}

stock void LoagKv()
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/mapconfigs.cfg");

	if(!FileExists(szPath))
		SetFailState("Config file '%s' is not exists", szPath);

	if(kv) delete kv;
	kv = new KeyValues("Config");
	if(!kv.ImportFromFile(szPath))
		SetFailState("Error reading config file '%s'. Check encoding, should be utf-8.", szPath);

}