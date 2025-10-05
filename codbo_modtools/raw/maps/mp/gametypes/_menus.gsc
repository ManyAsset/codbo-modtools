#include maps\mp\_utility;
init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_class_allies"] = "class_marines";
	game["menu_changeclass_allies"] = "changeclass";
	game["menu_initteam_allies"] = "initteam_marines";
	game["menu_class_axis"] = "class_opfor";
	game["menu_changeclass_axis"] = "changeclass";
	game["menu_initteam_axis"] = "initteam_opfor";
	game["menu_class"] = "class";
	game["menu_changeclass"] = "changeclass";
	game["menu_changeclass_offline"] = "changeclass";
	game["menu_wager_side_bet"] = "sidebet";
	game["menu_wager_side_bet_player"] = "sidebet_player";
	game["menu_changeclass_wager"] = "changeclass_wager";
	game["menu_changeclass_custom"] = "changeclass_custom";
	game["menu_changeclass_barebones"] = "changeclass_barebones";
	if ( !level.console )
	{
		game["menu_callvote"] = "callvote";
		game["menu_muteplayer"] = "muteplayer";
		precacheMenu(game["menu_callvote"]);
		precacheMenu(game["menu_muteplayer"]);
		
		
		
		game["menu_eog_main"] = "endofgame";
		game["menu_eog_unlock"] = "menu_aar_unlocks_weapons";
		game["menu_eog_summary"] = "menu_aar_summary";
		
		precacheMenu(game["menu_eog_main"]);
		precacheMenu(game["menu_eog_unlock"]);
		precacheMenu(game["menu_eog_summary"]);	
	}
	else
	{
		game["menu_controls"] = "ingame_controls";
		game["menu_options"] = "ingame_options";
		game["menu_leavegame"] = "popup_leavegame";
		precacheMenu(game["menu_controls"]);
		precacheMenu(game["menu_options"]);
		precacheMenu(game["menu_leavegame"]);
	}
	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_class_allies"]);
	precacheMenu(game["menu_changeclass_allies"]);
	precacheMenu(game["menu_initteam_allies"]);
	precacheMenu(game["menu_class_axis"]);
	precacheMenu(game["menu_changeclass_axis"]);
	precacheMenu(game["menu_class"]);
	precacheMenu(game["menu_changeclass"]);
	precacheMenu(game["menu_initteam_axis"]);
	precacheMenu(game["menu_changeclass_offline"]);
	precacheMenu(game["menu_changeclass_wager"]);
	precacheMenu(game["menu_changeclass_custom"]);
	precacheMenu(game["menu_changeclass_barebones"]);
	precacheMenu(game["menu_wager_side_bet"]);
	precacheMenu(game["menu_wager_side_bet_player"]);
	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	level thread onPlayerConnect();
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvar("ui_deathicontext", "1");
		player.enableDeathIcons = true;
		
		player thread onMenuResponse();
	}
}
onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
		
		
		
		
			
		if ( response == "back" )
		{
			self closeMenu();
			self closeInGameMenu();
			if ( level.console )
			{
				if( menu == game["menu_changeclass"] || menu == game["menu_changeclass_offline"] || menu == game["menu_team"] || menu == game["menu_controls"] )
				{
	
					if( self.pers["team"] == "allies" )
						self openMenu( game["menu_class_allies"] );
					if( self.pers["team"] == "axis" )
						self openMenu( game["menu_class_axis"] );
				}
			}
			continue;
		}
		
		if(response == "changeteam" && ( level.allow_teamchange == "1" || self is_bot() ) )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_team"]);
		}
	
		if(response == "changeclass_marines" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_allies"] );
			continue;
		}
		if(response == "changeclass_opfor" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_axis"] );
			continue;
		}
		if(response == "changeclass_wager" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_wager"] );
			continue;
		}
		if(response == "changeclass_custom" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_custom"] );
			continue;
		}
		if(response == "changeclass_barebones" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_barebones"] );
			continue;
		}
		if(response == "changeclass_marines_splitscreen" )
			self openMenu( "changeclass_marines_splitscreen" );
		if(response == "changeclass_opfor_splitscreen" )
			self openMenu( "changeclass_opfor_splitscreen" );
					
		
		if(response == "xpTextToggle")
		{
			self.enableText = !self.enableText;
			if (self.enableText)
				self setClientDvar( "ui_xpText", "1" );
			else
				self setClientDvar( "ui_xpText", "0" );
			continue;
		}
		
		if(response == "waypointToggle")
		{
			self.enable3DWaypoints = !self.enable3DWaypoints;
			if (self.enable3DWaypoints)
				self setClientDvar( "ui_3dwaypointtext", "1" );
			else
				self setClientDvar( "ui_3dwaypointtext", "0" );
			continue;
		}
		
		if(response == "deathIconToggle")
		{
			self.enableDeathIcons = !self.enableDeathIcons;
			if (self.enableDeathIcons)
				self setClientDvar( "ui_deathicontext", "1" );
			else
				self setClientDvar( "ui_deathicontext", "0" );
			self maps\mp\gametypes\_deathicons::updateDeathIconsEnabled();
			continue;
		}
		
		if(response == "endgame")
		{
			
			if(level.splitscreen)
			{
				if ( level.console )
					endparty();
				level.skipVote = true;
				if ( !level.gameEnded )
				{
					level thread maps\mp\gametypes\_globallogic::forceEnd();
				}
			}
				
			continue;
		}
		
		if(response == "killserverpc")
		{
			if( self isHost() )
			{
				self setclientdvar( "g_scriptMainMenu", "" );	
				self setclientdvar( "ui_showEndOfGame", "0" );
				level thread maps\mp\gametypes\_globallogic::killserverPc();
			}

			continue;
		}
		if ( response == "endround" )
		{
			if( self isHost() )
			{
				if ( !level.gameEnded )
				{
					level thread maps\mp\gametypes\_globallogic::forceEnd();
				}
				else
				{
					self closeMenu();
					self closeInGameMenu();
					self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
				}			
			}
			continue;
		}
		if(menu == game["menu_team"] && ( level.allow_teamchange == "1" || self is_bot() ) )
		{
			switch(response)
			{
			case "allies":
				
				
				self [[level.allies]]();
				break;
			case "axis":
				
				
				self [[level.axis]]();
				break;
			case "autoassign":
				
				
				self [[level.autoassign]]();
				break;
			case "spectator":
				
				
				self [[level.spectator]]();
				break;
			}
		}	
		else if( menu == game["menu_changeclass"] || menu == game["menu_changeclass_offline"] || menu == game["menu_changeclass_wager"] || menu == game["menu_changeclass_custom"] || menu == game["menu_changeclass_barebones"] )
		{
			self closeMenu();
			self closeInGameMenu();
			
			if(  level.rankedMatch && isSubstr(response, "custom") )
			{
				if ( self IsItemLocked( maps\mp\gametypes\_rank::GetItemIndex( "feature_cac" ) ) )
				kick( self getEntityNumber() );
			}
			self.selectedClass = true;
			self [[level.class]](response);
		}
		
		if ( ( menu == game["menu_wager_side_bet"] ) || ( menu == game["menu_wager_side_bet_player"] ) )
		{
			switch( response )
			{
				case "sidebet_p1":
					self maps\mp\gametypes\_wager::HandleNewSideBet( level.sideBetPlayers[0] );
					break;
				
				case "sidebet_p2":
					self maps\mp\gametypes\_wager::HandleNewSideBet( level.sideBetPlayers[1] );
					break;
				
				case "sidebet_p3":
					self maps\mp\gametypes\_wager::HandleNewSideBet( level.sideBetPlayers[2] );
					break;
					
				case "sidebet_bet":
					self maps\mp\gametypes\_wager::HandleNewSideBet( self );
				break;
			}
		}
	}
} 
 
 
