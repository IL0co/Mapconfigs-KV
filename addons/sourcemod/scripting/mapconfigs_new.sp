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
	if(!kv)
		LoagKv();
		
	ExecuteMapSpecificConfigs();
}

public void OnMapEnd()
{
	LoagKv();
}

stock void ExecuteMapSpecificConfigs() 
{
	char szMap[128];
	GetCurrentMap(szMap, sizeof(szMap));
	ApplyMapNameFix(szMap, sizeof(szMap));

	char buffMapName[32], buffCmdName[64], buffCmdValue[32];

	kv.Rewind();
	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(buffMapName, sizeof(buffMapName));
			if(StrContains(szMap, buffMapName, false) != -1 && kv.GotoFirstSubKey(false))
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

stock void ApplyMapNameFix(char[] szMapNameBuffer, int iBufferLength)
{
	// First, try find UNIX slash.
	int iSlashPos = FindCharInString(szMapNameBuffer, '/', true);
	if (iSlashPos == -1)
	{
		// Then, Windows.
		iSlashPos = FindCharInString(szMapNameBuffer, '\\', true);
		if (iSlashPos == -1)
		{
			// No one slash has found.
			return;
		}
	}

	// Apply fix.
	strcopy(szMapNameBuffer, iBufferLength, szMapNameBuffer[iSlashPos+1]);
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