#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
main()
{
	PrintLn( "Alex 'SparkyMcSparks' Romo" );
	PrintLn( "aromo@treyarch.com" ); 
	PrintLn( "'Juggernaut Beta'" );
	PrintLn( "Objective (Juggernaut): Kill as many regular players as possible before being overrun. You gain points by getting kills as a Juggernaut and staying alive." );
	PrintLn( "Objective (Axis): Hunt down Juggernaut players." );
	PrintLn( "Map ends: Then a [Juggernaut] player reaches the score limit, or time limit is reached" );
	PrintLn( "Axis respawn as Juggernaut when they die, and Juggernaut players respawn as Axis when they die" );
	
	if( GetDvar( #"mapname" ) == "mp_background" )
	{
		return;
	}
	
	PreCacheShader( "juggernaut_goggles_overlay" );
	PreCacheModel( "c_rus_heavy_fb_mp" );
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( "jug", 10, 0, 1440 );
	maps\mp\gametypes\_globallogic_utils::registerScoreLimitDvar( "jug", 100, 0, 50000 );
	maps\mp\gametypes\_globallogic_utils::registerRoundLimitDvar( "jug", 1, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerRoundWinLimitDvar( "jug", 0, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerNumLivesDvar( "jug", 0, 0, 10 );
	maps\mp\gametypes\_weapons::registerGrenadeLauncherDudDvar( level.gameType, 10, 0, 1440 );
	maps\mp\gametypes\_weapons::registerThrownGrenadeDudDvar( level.gameType, 0, 0, 1440 );
	maps\mp\gametypes\_weapons::registerKillstreakDelay( level.gameType, 0, 0, 1440 );
	maps\mp\gametypes\_globallogic::registerFriendlyFireDelay( level.gameType, 15, 0, 1440 );
	
	
	
	level.scoreRoundBased = true;
	level.teamBased = true;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onSpawnPlayerUnified = ::onSpawnPlayerUnified;
	level.onRoundEndGame = ::onRoundEndGame;
	game[ "dialog" ][ "gametype" ] = "tdm_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hctdm_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	
	setscoreboardcolumns( "kills", "deaths", "kdratio", "assists" );
	if ( GetDvar( "scr_juggernaut_scorepointalive_delay" ) == "" )
	{
		SetDvar( "scr_juggernaut_scorepointalive_delay", "15" );
	}
	level.scorePointAliveDelay = GetDvarInt( "scr_juggernaut_scorepointalive_delay" );
	level thread onPlayerConnect();
}

juggernautTeamSet()
{
	
	
	
	
	
	
	SetDvar( "g_TeamName_Allies", &"JUGGERNAUT_SHORT" );
	
	game[ "strings" ][ "allies_win" ] = &"JUGGERNAUT_WIN_MATCH";
	game[ "strings" ][ "allies_win_round" ] = &"JUGGERNAUT_WIN_ROUND";
	game[ "strings" ][ "allies_mission_accomplished" ] = &"JUGGERNAUT_MISSION_ACCOMPLISHED";
	game[ "strings" ][ "allies_eliminated" ] = &"JUGGERNAUT_ELIMINATED";
	game[ "strings" ][ "allies_forfeited" ] = &"JUGGERNAUT_FORFEITED";
	game[ "strings" ][ "allies_name" ] = &"JUGGERNAUT_NAME";
	
}

onStartGameType()
{
	level.juggernautsAllowed = 1;
	SetDvar( "scr_teambalance", 0 );
	SetDvar( "scr_disable_cac", 1 );
	MakeDvarServerInfo( "scr_disable_cac", 1 );
	SetDvar( "scr_disable_weapondrop", 1 );
	SetDvar( "scr_game_perks", 0 );
	level.killstreaksenabled = 0;
	level.hardpointsenabled = 0;
	setClientNameMode( "auto_change" );
	juggernautTeamSet();
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "allies", &"OBJECTIVES_TDM" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "axis", &"OBJECTIVES_TDM" );
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_TDM" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_TDM" );
	}
	else
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_TDM_SCORE" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_TDM_SCORE" );
	}
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "allies", &"OBJECTIVES_TDM_HINT" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "axis", &"OBJECTIVES_TDM_HINT" );
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawning::updateAllSpawnPoints();
	level.spawn_axis_start= maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_axis_start" );
	level.spawn_allies_start= maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_allies_start" );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getRandomIntermissionPoint();
	setDemoIntermissionPoint( spawnpoint.origin, spawnpoint.angles );
	allowed[ 0 ] = "tdm";
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main( allowed );
	
	maps\mp\gametypes\_spawning::create_map_placed_influencers();
	
	
	if ( !isOneRound() )
	{
		level.displayRoundEndText = true;
		if ( level.numLives )
		{
			
			level.overrideTeamScore = true;
			level.onEndGame = ::onEndGame;
		}
		else if( isScoreRoundBased() )
		{
			maps\mp\gametypes\_globallogic_score::resetTeamScores();
		}
	}
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	level thread fakeIndividualScore();
}

getSpawnPoint()
{
	spawnteam = self.pers[ "team" ];
	if ( IsDefined( game[ "switchedsides" ] ) && game[ "switchedsides" ] )
	{
		spawnteam = getOtherTeam( spawnteam );
	}
	if ( level.inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + spawnteam + "_start" );
		if ( !spawnPoints.size )
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_sab_spawn_" + spawnteam + "_start" );
		if ( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	return spawnPoint;
}

onSpawnPlayerUnified()
{
	self.usingObj = undefined;
	if ( level.useStartSpawns && !level.inGracePeriod )
	{
		level.useStartSpawns = false;
	}
	maps\mp\gametypes\_spawning::onSpawnPlayer_Unified();
}

onSpawnPlayer()
{
	pixbeginevent( "TDM:onSpawnPlayer" );
	self.usingObj = undefined;
	if ( level.inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + self.pers[ "team" ] + "_start" );
		if ( !spawnPoints.size )
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_sab_spawn_" + self.pers[ "team" ] + "_start" );
		if ( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers[ "team" ] );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers[ "team" ] );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	self spawn( spawnPoint.origin, spawnPoint.angles, "tdm" );
	pixendevent();
}

onEndGame( winningTeam )
{
	if ( IsDefined( winningTeam ) && ( winningTeam == "allies" || winningTeam == "axis" ) )
	{
		[[ level._setTeamScore ]]( winningTeam, [[ level._getTeamScore ]]( winningTeam ) + 1 );
	}
}

onRoundEndGame( roundWinner )
{
	if ( game[ "roundswon" ][ "allies" ] == game[ "roundswon" ][ "axis" ] )
	{
		winner = "tie";
	}
	else if ( game[ "roundswon" ][ "axis" ] > game[ "roundswon" ][ "allies" ] )
	{
		winner = "axis";
	}
	else
	{
		winner = "allies";
	}
	return winner;
}

onScoreCloseMusic()
{
	while( !level.gameEnded )
	{
		axisScore = [[ level._getTeamScore ]]( "axis" );
		alliedScore = [[ level._getTeamScore ]]( "allies" );
		scoreLimit = level.scoreLimit;
		scoreThreshold = scoreLimit * .1;
		scoreDif = abs( axisScore - alliedScore );
		scoreThresholdStart = abs( scoreLimit - scoreThreshold );
		scoreLimitCheck = scoreLimit - 10;
		if ( alliedScore > axisScore )
		{
			currentScore = alliedScore;
		}
		else
		{
			currentScore = axisScore;
		}
		if ( scoreDif <= scoreThreshold && scoreThresholdStart <= currentScore )
		{
			
			thread maps\mp\gametypes\_globallogic_audio::set_music_on_team( "TIME_OUT", "both" );
			thread maps\mp\gametypes\_globallogic_audio::actionMusicSet();
			return;
		}
		wait( .5 );
	}
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self endon( "spawned" );
	if( self.sessionteam == "spectator" )
	{
		return;
	}
	if( IsPlayer( attacker ) || IsDefined( self.pers[ "isBot" ] )  )
	{
		if ( attacker == self )
		{
			
			if( self.pers[ "team" ] == "allies" )
			{
				if( getSizeOfTeam( "axis" ) < 1 )
				{
					return;
				}
				if( getSizeOfTeam( "axis" ) == 1 )
				{
					players = GetEntArray( "player", "classname" );
					for( x = 0; x < players.size; x++ )
					{
						if( players[ x ].pers[ "team" ] == "axis" )
						{
							players[ x ] thread makeJuggernaut( true );
							self thread makeJuggernaut( false );
							return;
						}
					}
				}
				self thread makeJuggernaut( false );
				thread checkJuggernautBalance( undefined, self );
			}
			return;
		}
		else if( self.pers[ "team" ] == attacker.pers[ "team" ] )
		{
			
			if( attacker.pers[ "team" ] == "allies" )
			{
				attacker thread makeJuggernaut( false );
				thread checkJuggernautBalance();
			}
			return;
		}
		else
		{
			if( self.pers[ "team" ] == "allies" )
			{
				
				
				self thread makeJuggernaut( false );
				setMaxJuggernauts( getSizeOfTeam( "axis" ) );
				if( getSizeOfTeam( "allies" ) < level.juggernautsAllowed )
				{
					
					attacker thread makeJuggernaut( true );
				}
				else
				{
					
				}
				return;
			}
			else
			{
				
				
				if( IsDefined( attacker ) )
				{
					attacker.score += 5;
				}
				return;
			}
		}
	}
	else
	{
		
		if( self.pers[ "team" ] == "allies" )
		{
			if( getSizeOfTeam( "axis" ) < 1 )
			{
				return;
			}
			else
			{
				self thread makeJuggernaut( false );
				thread checkJuggernautBalance( undefined, self );
				return;
			}
		}
	}
}

scorePointsAliveJuggernaut()
{
	level endon( "game_ended" );
	self endon( "death" );
	while( IsAlive( self ) )
	{
		wait ( level.scorePointAliveDelay );
		self.score += 2;
	}
}

checkJuggernautBalance( moveMe, dontMoveMe )
{
	numAllies = 0;
	numAxis = 0;
	alliedPlayers = [ ];
	axisPlayers = [ ];
	players = GetEntArray( "player", "classname" );
	for( x = 0; x < players.size; x++ )
	{
		player = players[ x ];
		if( IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "allies" )
		{
			alliedPlayers[ alliedPlayers.size ] = player;
			numAllies++;
		}
		else if( IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "axis" )
		{
			axisPlayers[ axisPlayers.size ] = player;
			numAxis++;
		}
	}
	setMaxJuggernauts( numAxis );
	if( numAllies == level.juggernautsAllowed )
	{
		return;
	}
	if( numAllies < level.juggernautsAllowed )
	{
		if( IsDefined( moveMe ) && IsDefined( moveMe.pers[ "team" ] ) && moveMe.pers[ "team" ] != "allies" )
		{
			moveMe makeJuggernaut( true );
		}
		else if( IsDefined( dontMoveMe ) )
		{
			makeRandomJuggernaut( dontMoveMe );
		}
		else
		{
			makeRandomJuggernaut( undefined );
		}
		
		return;
	}
	if( ( numAllies > ( level.juggernautsAllowed + 1 ) ) || ( ( numAllies > level.juggernautsAllowed ) && ( level.juggernautsAllowed == 1 ) ) )
	{
		demoteRandomJuggernaut();
		
		return;
	}
}

setMaxJuggernauts( numAxis )
{
	if( numAxis > 30 )
	{
		level.juggernautsAllowed = 11;
	}
	if( numAxis > 27 )
	{
		level.juggernautsAllowed = 10;
	}
	if( numAxis > 24 )
	{
		level.juggernautsAllowed = 9;
	}
	if( numAxis > 21 )
	{
		level.juggernautsAllowed = 8;
	}
	if( numAxis > 18 )
	{
		level.juggernautsAllowed = 7;
	}
	if( numAxis > 15 )
	{
		level.juggernautsAllowed = 6;
	}
	else if( numAxis > 12 )
	{
		level.juggernautsAllowed = 5;
	}
	else if( numAxis > 9 )
	{
		level.juggernautsAllowed = 4;
	}
	else if( numAxis > 6 )
	{
		level.juggernautsAllowed = 3;
	}
	else if( numAxis > 3 )
	{
		level.juggernautsAllowed = 2;
	}
	else
	{
		level.juggernautsAllowed = 1;
	}
}

makeJuggernaut( isJuggernaut )
{
	self endon( "disconnect" );
	if( IsDefined( isJuggernaut ) && isJuggernaut )
	{
		team = "allies";
	}
	else
	{
		isJuggernaut = false;
		team = "axis";
	}
	playerAlive = IsAlive( self );
	if( playerAlive )
	{
		self FreezeControls( true );
		self CloseMenu();
		self.health = self.maxhealth;
	}
	self.pers[ "team" ] = team;
	self.team = team;
	self.pers[ "savedmodel" ] = undefined;
	self.pers[ "teamTime" ] = 0;
	self.sessionteam = team;
	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;
	self maps\mp\gametypes\_globallogic_ui::updateObjectiveText();
	if( isJuggernaut )
	{
		self.isJuggernaut = true;
		self SetMoveSpeedScale( 0.6 );
		self.juggernautOverlay = NewClientHudElem( self );
		self.juggernautOverlay.x = 0;
		self.juggernautOverlay.y = 0;
		self.juggernautOverlay.alignX = "left";
		self.juggernautOverlay.alignY = "top";
		self.juggernautOverlay.horzAlign = "fullscreen";
		self.juggernautOverlay.vertAlign = "fullscreen";
		self.juggernautOverlay SetShader ( "juggernaut_goggles_overlay", 640, 480 );
		self.juggernautOverlay.sort = -10;
		self.juggernautOverlay.archived = true;
		self thread scorePointsAliveJuggernaut();
		self DetachAll();
		self SetModel( "c_rus_heavy_fb_mp" );
		self TakeAllWeapons();
		self GiveWeapon( "m60_extclip_mp" );
		self SetOffhandSecondaryClass( "frag_grenade_mp" );
		self GiveWeapon( "frag_grenade_mp" );
		self SetWeaponAmmoClip( "frag_grenade_mp", 2 );
		self thread infiniteAmmo();
		self.maxhealth = 384;
		self.health = 384;
	}
	else
	{
		if ( self HasPerk( "specialty_armorvest" ) )
		{
			self UnSetPerk( "specialty_armorvest" );
		}
		self.maxhealth = 100;
		self.health = 100;
		self notify( "jugg_removed" );
		self SetMoveSpeedScale( 1.0 );
		
		self.isJuggernaut = false;
		self.isJuggernautDef = false;
		if( IsDefined( self.juggernautOverlay ) )
		{
			self.juggernautOverlay Destroy();
		}
		self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );
	}
	if( playerAlive )
	{
		spawnPoint = self getSpawnPoint();
		self SetOrigin( spawnPoint.origin );
		self SetPlayerAngles( spawnPoint.angles );
		self notify( "weapon_change", "none" );
		self thread maps\mp\gametypes\_friendicons::showFriendIcon();
		self FreezeControls( false );
	}
	self notify( "joined_team" );
}

makeRandomJuggernaut( dontIncludeMe )
{
	candidates = [ ];
	axisPlayers = [ ];
	players = GetEntArray( "player", "classname" );
	for( x = 0; x < players.size; x++ )
	{
		player = players[ x ];
		if( IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "axis" )
		{
			axisPlayers[ axisPlayers.size ] = player;
			if( ( IsDefined( dontIncludeMe ) ) && ( dontIncludeMe == player ) )
			{
				continue;
			}
			candidates[ candidates.size ] = player;
		}
	}
	if( axisPlayers.size == 1 )
	{
		num = RandomInt( axisPlayers.size );
		
		axisPlayers[ num ] makeJuggernaut( true );
	}
	else if( axisPlayers.size > 1 )
	{
		if( candidates.size > 0 )
		{
			num = RandomInt( candidates.size );
			
			candidates[ num ] makeJuggernaut( true );
			return;
		}
		else
		{
			num = RandomInt( axisPlayers.size );
			
			axisPlayers[ num ] makeJuggernaut( true );
			return;
		}
	}
}

demoteRandomJuggernaut()
{
	numAllies = 0;
	alliedPlayers = [ ];
	players = GetEntArray( "player", "classname" );
	for( x = 0; x < players.size; x++ )
	{
		player = players[ x ];
		if( IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "allies" )
		{
			alliedPlayers[ alliedPlayers.size ] = player;
			numAllies++;
		}
	}
	if( numAllies > 0 )
	{
		num = RandomInt( alliedPlayers.size );
		
		alliedPlayers[ num ] thread makeJuggernaut( false );
	}
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
		player thread onPlayerDisconnect();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	for( ;; )
	{
		self waittill( "spawned_player" );
		
		if( self.pers[ "team" ] == "allies" && ( !IsDefined( self.isJuggernaut ) || ( IsDefined( self.isJuggernaut ) && self.isJuggernaut == false ) ) )
		{
			self thread scorePointsAliveJuggernaut();
			wait( 0.5 );
			self DetachAll();
			self SetModel( "c_rus_heavy_fb_mp" );
		}
		thread checkJuggernautBalance();
	}
}

onPlayerDisconnect()
{
	level endon( "game_ended" );
	self waittill( "disconnect" );
	checkJuggernautBalance( undefined, undefined );
}

getSizeOfTeam( team )
{
	players = GetEntArray( "player", "classname" );
	playerNum = 0;
	for( x = 0; x < players.size; x++ )
	{
		if( IsDefined( players[ x ].pers[ "team" ] ) && players[ x ].pers[ "team" ] == team )
		{
			playerNum++;
		}
	}
	return playerNum;
}

fakeIndividualScore()
{
	
	level endon( "game_ended" );
	while( 1 )
	{
		players = GetEntArray( "player", "classname" );
		highScore = 0;
		for( x = 0; x < players.size; x++ )
		{
			player = players[ x ];
			if( IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "allies" && player.score > highScore )
			{
				highScore = player.score;
			}
		}
		[[ level._setTeamScore ]]( "allies", highScore );
		wait ( 0.5 );
	}
}

infiniteAmmo()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "jugg_removed" );
	for ( ;; )
	{
		wait( 0.1 );
		weapon = self GetCurrentWeapon();
		if( weapon == "m60_extclip_mp" )
		{
			self GiveMaxAmmo( weapon );
		}
	}
}