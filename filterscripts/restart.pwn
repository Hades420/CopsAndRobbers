// ----- DEFINES -----

#define FILTERSCRIPT
#define DEBUG

// ----- INCLUDES -----

#include <a_samp>

// ----- GLOBAL VARIABLES -----

new IsRestarting = 0;
new UnloadTimer = -1;

// ----- FUNCTIONS -----

SendMessage(message[])
{
#if defined DEBUG
	print(message);
#endif
	return 1;
}

// ----- CALLBACKS -----

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	SendMessage("RESTART: OnFilterScriptInit");
	
	// Tell the script we are currently restarting.
	IsRestarting = 1;
	
	// We're simulating what happens during /rcon gmx
	new pVarCount = 0;
	new pVarName[128];
	
	for(new playerid = 0, count = GetPlayerPoolSize(); playerid <= count; playerid++)
	{
	    if(IsPlayerConnected(playerid) == 0) continue;

		// Tell them the server is restarting.
		SendClientMessage(playerid, -1, "The server is restarting..");
		
		// De-spawn them from the world.
		// When they respawn we want them in class selection.
		ForceClassSelection(playerid); 
		// Hide the controls for now.
		TogglePlayerSpectating(playerid, true);
		
		// Set their camera position.
		// /save -- 1133.0504,-2038.4034,69.1000,270.0
		SetPlayerCameraPos(playerid, 1133.0504, -2038.4034, 69.1000);
		
	    // Reset the player variables.
 		pVarCount = GetPVarsUpperIndex(playerid);

		for(new i = 0; i <= pVarCount; i++)
		{
		    strdel(pVarName, 0, strlen(pVarName));
		    GetPVarNameAtIndex(playerid, i, pVarName, 128);
		    
		    if(GetPVarType(playerid, pVarName) != PLAYER_VARTYPE_NONE)
			{
			    DeletePVar(playerid, pVarName);
		    }
		}
		
		// Console output
		SendMessage("RESTART: FAKE OnPlayerDisconnect");
	}
	
	if(UnloadTimer != -1)
	{
	    KillTimer(UnloadTimer);
	    UnloadTimer = -1;
	}
	
	UnloadTimer = SetTimer("UnloadFilterScript", 1000, false);
	return 1;
}

forward UnloadFilterScript();
public UnloadFilterScript()
{
	// This will crash the server, you'll have to manually unloadfs =[
	// SendRconCommand("unloadfs restart");
	return 1;
}

public OnFilterScriptExit()
{
	SendMessage("RESTART: OnFilterScriptExit");

	// Kill our timer.
	if(UnloadTimer != -1)
	{
	    KillTimer(UnloadTimer);
	    UnloadTimer = -1;
	}

	// Tell the script we're no longer restarting.
	IsRestarting = 0;
	
	// Get server information for connecting message.
	new serverPort = GetConsoleVarAsInt("port");
	new hostname[64];
	new message1[144];
	new message3[144];
	
	GetConsoleVarAsString("hostname", hostname, 64);
	format(message1, 144, "Connecting to :%i...", serverPort);
	format(message3, 144, "Connected to %s", hostname);
	
	// We're simulating OnPlayerConnect
	for(new playerid = 0, count = GetPlayerPoolSize(); playerid <= count; playerid++)
	{
	    if(IsPlayerConnected(playerid) == 0) continue;

		// Tell them they're "connected" to the server.
		SendClientMessage(playerid, -1, message1);
		SendClientMessage(playerid, -1, "Connected. Joining game...");
		SendClientMessage(playerid, -1, message3);
		
		// Set the camera position to the class selection camera position.
		// /save -- 50.0000,50.0000,70.0000,270.0000
		SetPlayerCameraPos(playerid, 50.0000, 50.0000, 70.0000);
		
		// Show the controls for the player.
		TogglePlayerSpectating(playerid, false);
		
		// Console output
		SendMessage("RESTART: FAKE OnPlayerConnect");
	}
	return 1;
}

#else

main() {}

#endif

public OnPlayerUpdate(playerid)
{
	return (IsRestarting == 0) ? 1 : 0;
}

// ----- END OF CALLBACKS -----

