#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\hns_assets;
main()
{
	PrintLn( "Alex 'SparkyMcSparks' Romo" );
	PrintLn( "aromo@treyarch.com" );
	PrintLn( "'Hide N' Seek Beta'" );
	PrintLn( "Objective: Hide from the seekers." );
	PrintLn( "Map ends: Time limited reached, or all hiders are found." );
	PrintLn( "Respawning: No wait / Join seeker." );

	if( GetDvar( "mapname" ) == "mp_background" )
	{
		return;
	}
	
	if( !mapSupport() )
	{
		error( "Could not find any available models to use." );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	collMapListGenerate();
	if( GetDvar( "scr_hns_hidegracetime" ) == "" )
	{
		SetDvar( "scr_hns_hidegracetime", "45" );
	}
	level.hidingGracePeriod = GetDvarInt( "scr_hns_hidegracetime" );
	if( GetDvarInt( "scr_hns_maxusablemodels" ) < 1 )
	{
		SetDvar( "scr_hns_maxusablemodels", 300 );
	}
	level.MAX_USUABLE_MODELS = GetDvarInt( "scr_hns_maxusablemodels" );
	if( GetDvar( "scr_hns_displaymodelname" ) == "" )
	{
		SetDvar( "scr_hns_displaymodelname", "0" );
	}
	level.DISPLAY_MODELNAME = GetDvarInt( "scr_hns_displaymodelname" );
	onPrecacheGameModels();
	level.giveCustomLoadout = ::giveCustomLoadout;
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	maps\mp\gametypes\_globallogic_utils::registerRoundSwitchDvar( level.gameType, 3, 0, 9 );
	maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( level.gameType, 2.5 + ( level.hidingGracePeriod / 60 ), 0, 1440 );
	maps\mp\gametypes\_globallogic_utils::registerScoreLimitDvar( level.gameType, 4, 0, 500 );
	maps\mp\gametypes\_globallogic_utils::registerRoundLimitDvar( level.gameType, 0, 0, 15 );
	maps\mp\gametypes\_globallogic_utils::registerRoundWinLimitDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerNumLivesDvar( level.gameType, 1, 0, 10 );

	level.gametype = "tdm";
	level.fullGameTypeName = "tdm";
	level.teamBased = true;
	level.overrideTeamScore = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onSpawnPlayerUnified = ::onSpawnPlayerUnified;
	level.playerSpawnedCB = ::hns_playerSpawnedCB;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onDeadEvent = ::onDeadEvent;
	level.onOneLeftEvent = ::onOneLeftEvent;
	level.onTimeLimit = ::onTimeLimit;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onRoundEndGame = ::onRoundEndGame;
	level.endGameOnScoreLimit = false;
	game[ "dialog" ][ "gametype" ] = "sd_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hcsd_start";
	game[ "dialog" ][ "sudden_death" ] = "generic_boost";
	game[ "dialog" ][ "last_one" ] = "encourage_last";
	game[ "dialog" ][ "halftime" ] = "sd_halftime";
	setscoreboardcolumns( "kills", "deaths", "kdratio", "assists" );
	level thread onPlayerConnect();
}

HNS_TeamSet()
{

	SetDvar( "g_TeamIcon_Axis", "icon_hiders" );
	SetDvar( "g_TeamIcon_Allies", "icon_seekers" );

	game[ "entity_headicon_allies" ] = "icon_seekers";
	game[ "entity_headicon_axis" ] = "icon_hiders";
	game[ "headicon_allies" ] = "icon_seekers";
	game[ "headicon_axis" ] = "icon_hiders";

	SetDvar( "g_TeamName_Allies", &"HIDEANDSEEK_SEEKERS_SHORT" );
	SetDvar( "g_TeamName_Axis", &"HIDEANDSEEK_HIDERS_SHORT" );

	game[ "strings" ][ "allies_win" ] = &"HIDEANDSEEK_SEEKERS_WIN_MATCH";
	game[ "strings" ][ "allies_win_round" ] = &"HIDEANDSEEK_SEEKERS_WIN_ROUND";
	game[ "strings" ][ "allies_mission_accomplished" ] = &"HIDEANDSEEK_SEEKERS_MISSION_ACCOMPLISHED";
	game[ "strings" ][ "allies_eliminated" ] = &"HIDEANDSEEK_SEEKERS_ELIMINATED";
	game[ "strings" ][ "allies_forfeited" ] = &"HIDEANDSEEK_SEEKERS_FORFEITED";
	game[ "strings" ][ "allies_name" ] = &"HIDEANDSEEK_SEEKERS_NAME";
	game[ "icons" ][ "allies" ] = "icon_seekers";
	game[ "strings" ][ "axis_win" ] = &"HIDEANDSEEK_HIDERS_WIN_MATCH";
	game[ "strings" ][ "axis_win_round" ] = &"HIDEANDSEEK_HIDERS_WIN_ROUND";
	game[ "strings" ][ "axis_mission_accomplished" ] = &"HIDEANDSEEK_HIDERS_MISSION_ACCOMPLISHED";
	game[ "strings" ][ "axis_eliminated" ] = &"HIDEANDSEEK_HIDERS_ELIMINATED";
	game[ "strings" ][ "axis_forfeited" ] = &"HIDEANDSEEK_HIDERS_FORFEITED";
	game[ "strings" ][ "axis_name" ] = &"HIDEANDSEEK_HIDERS_NAME";
	game[ "icons" ][ "axis" ] = "icon_hiders";
}

checkAllowSpectating()
{
	wait ( 0.05 );
	update = false;
	if( !level.aliveCount[ game[ "attackers" ] ] )
	{
		level.spectateOverride[game[ "attackers" ]].allowEnemySpectate = 1;
		update = true;
	}
	if( !level.aliveCount[ game[ "defenders" ] ] )
	{
		level.spectateOverride[game[ "defenders" ] ].allowEnemySpectate = 1;
		update = true;
	}
	if( update )
	{
		maps\mp\gametypes\_spectating::updateSpectateSettings();
	}
}

onPrecacheGameType()
{
	PreCacheShader( "icon_hiders" );
	PreCacheShader( "icon_seekers" );
	PreCacheString( &"HIDEANDSEEK_HIDER_CONTROL_A_1" );
	PreCacheString( &"HIDEANDSEEK_HIDER_CONTROL_A_2" );
	PreCacheString( &"HIDEANDSEEK_HIDER_CONTROL_B" );
	PreCacheString( &"HIDEANDSEEK_HIDER_CONTROL_C" );
	precacheSlide( "hideandseek_tut1_a", &"HIDEANDSEEK_TUT1_A" );
	precacheSlide( "hideandseek_tut1_b", &"HIDEANDSEEK_TUT1_B" );
	precacheSlide( "hideandseek_tut2_a", &"HIDEANDSEEK_TUT2_A" );
	precacheSlide( "hideandseek_tut2_b", &"HIDEANDSEEK_TUT2_B" );
	precacheSlide( "hideandseek_tut3_a", &"HIDEANDSEEK_TUT3_A" );
	precacheSlide( "hideandseek_tut3_b", &"HIDEANDSEEK_TUT3_B" );
	precacheSlide( "hideandseek_tut4_a", &"HIDEANDSEEK_TUT4_A" );
	precacheSlide( "hideandseek_tut4_b", &"HIDEANDSEEK_TUT4_B" );
}

onStartGameType()
{
	if( !IsDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = false;
	}
	if( game[ "switchedsides" ] )
	{
		oldAttackers = game[ "attackers" ] ;
		oldDefenders = game[ "defenders" ];
		game[ "attackers" ] = oldDefenders;
		game[ "defenders" ] = oldAttackers;
	}
	SetClientNameMode( "manual_change" );
	HNS_TeamSet();
	SetDvar( "scr_teambalance", 0 );
	SetDvar( "scr_disable_cac", 1 );
	MakeDvarServerInfo( "scr_disable_cac", 1 );
	SetDvar( "scr_disable_weapondrop", 1 );
	SetDvar( "scr_game_perks", 0 );
	level.killstreaksenabled = 0;
	level.hardpointsenabled = 0;
	SetDvar( "xblive_privatematch", 0 );
	MakeDvarServerInfo( "xblive_privatematch", 0 );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "allies", &"HIDEANDSEEK_OBJECTIVE_SEEKERS" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "axis", &"HIDEANDSEEK_OBJECTIVE_HIDERS" );
	if( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"HIDEANDSEEK_OBJECTIVE_SEEKERS" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"HIDEANDSEEK_OBJECTIVE_HIDERS" );
	}
	else
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"HIDEANDSEEK_OBJECTIVE_SEEKERS_SCORE" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"HIDEANDSEEK_OBJECTIVE_HIDERS_SCORE" );
	}
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "allies", &"HIDEANDSEEK_OBJECTIVE_SEEKERS_HINT" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "axis", &"HIDEANDSEEK_OBJECTIVE_HIDERS_HINT" );
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

	level thread HideAndSeek_Main();
}

HideAndSeek_Main()
{
	addSlide( "hideandseek_tut1_a", &"HIDEANDSEEK_TUT1_A" );
	addSlide( "hideandseek_tut1_b", &"HIDEANDSEEK_TUT1_B" );
	addSlide( "hideandseek_tut2_a", &"HIDEANDSEEK_TUT2_A" );
	addSlide( "hideandseek_tut2_b", &"HIDEANDSEEK_TUT2_B" );
	addSlide( "hideandseek_tut3_a", &"HIDEANDSEEK_TUT3_A" );
	addSlide( "hideandseek_tut3_b", &"HIDEANDSEEK_TUT3_B" );
	addSlide( "hideandseek_tut4_a", &"HIDEANDSEEK_TUT4_A" );
	addSlide( "hideandseek_tut4_b", &"HIDEANDSEEK_TUT4_B" );

	level.SeekingHasBegun = false;
	level._effect[ "hider_killed" ]	= LoadFX( "maps/zombie/fx_zmbtron_bear_butterfly" );
	level waittill ( "prematch_over" );
	array_thread( getSeekers(), ::freeze_player_controls, true );
	CoverSeekerEyes = CreateServerIcon( "black", 640, 480 , game[ "attackers" ] );
	CoverSeekerEyes.sort = -2;
	CoverSeekerEyes.horzAlign = "fullscreen";
	CoverSeekerEyes.vertAlign = "fullscreen";
	thread playSlides();
	timerDisplay = [];
	timerDisplay[ "allies" ] = createServerTimer( "objective", 1.4, game[ "attackers" ] );
	timerDisplay[ "allies" ].sort = -1;
	timerDisplay[ "allies" ] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	timerDisplay[ "allies" ].label = &"HIDEANDSEEK_HIDE_GRACEPERIOD_SEEKERS";
	timerDisplay[ "allies" ].alpha = 0;
	timerDisplay[ "allies" ].archived = false;
	timerDisplay[ "allies" ].hideWhenInMenu = true;
	timerDisplay[ "axis"  ] = createServerTimer( "objective", 1.4, game[ "defenders" ] );
	timerDisplay[ "axis"  ].sort = -1;
	timerDisplay[ "axis"  ] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	timerDisplay[ "axis"  ].label = &"HIDEANDSEEK_HIDE_GRACEPERIOD_HIDERS";
	timerDisplay[ "axis"  ].alpha = 0;
	timerDisplay[ "axis"  ].archived = false;
	timerDisplay[ "axis"  ].hideWhenInMenu = true;
	thread hideTimerDisplayOnGameEnd( timerDisplay[ "allies" ] );
	thread hideTimerDisplayOnGameEnd( timerDisplay[ "axis" ] );
	timerDisplay[ "allies" ].label = &"HIDEANDSEEK_HIDE_GRACEPERIOD_SEEKERS";
	timerDisplay[ "allies" ] setTimer( level.hidingGracePeriod );
	timerDisplay[ "allies" ].alpha = 1;
	timerDisplay[ "axis"  ].label = &"HIDEANDSEEK_HIDE_GRACEPERIOD_HIDERS";
	timerDisplay[ "axis"  ] setTimer( level.hidingGracePeriod );
	timerDisplay[ "axis"  ].alpha = 1;
	wait level.hidingGracePeriod;
	CoverSeekerEyes Destroy();
	timerDisplay[ "allies" ].alpha = 0;
	timerDisplay[ "axis"  ].alpha = 0;
	level.SeekingHasBegun = true;
	level notify ( "SeekingHasBegun" );
	array_thread( getSeekers(), ::freeze_player_controls, false );
}

makeHider()
{
	self TakeAllWeapons();
	self DisableWeapons();
	self AllowAds( false );
	self notify( "stop_ammo" );
	self SetClientDvars(
	"cg_thirdPerson", "1",
	"cg_thirdPersonAngle", "360",
	"cg_thirdPersonRange", "200" );
	self ClearPerks();
	self SetPerk( "specialty_quieter" );
	self SetPerk( "specialty_gpsjammer" );
	if( IsDefined( self.pers[ "myprop" ]  ) )
	{
		self.pers[ "myprop" ] Delete();
	}
	usableModelsKeys = GetArrayKeys( level.usableModels );
	self.pers[ "myprop" ] = spawn( "script_model", self.origin );
	self.pers[ "myprop" ].health = 10000;
	self.pers[ "myprop" ].owner = self;
	self.pers[ "myprop" ].angles = self.angles;
	self.pers[ "myprop" ].indexKey = RandomInt( level.MAX_USUABLE_MODELS );
	self.pers[ "myprop" ] SetModel( level.usableModels[ usableModelsKeys[ self.pers[ "myprop" ].indexKey ] ] );
	self.pers[ "myprop" ] SetCanDamage( true );
	self.pers[ "myprop" ] thread detachOnDisconnect( self );
	self.pers[ "myprop" ] thread attachModel( self );
	self thread monitorKeyPress();
}

makeSeeker()
{
	self EnableWeapons();
	self AllowAds( true );
	self thread infiniteAmmo();
	self thread damageOnFire();
	self SetClientDvars(
	"cg_thirdPerson", "0" );
	self ClearPerks();
	self SetPerk( "specialty_fastreload" );
	self SetPerk( "specialty_fastads" );
	self SetPerk( "specialty_sprintrecovery" );
	self SetPerk( "specialty_longersprint" );
	if( IsDefined( self.pers[ "myprop" ]  ) )
	{
		self.pers[ "myprop" ] Delete();
	}
	if( !level.SeekingHasBegun )
	{
		self freeze_player_controls( true );
	}
}

detachOnDisconnect( player )
{
	player endon( "death" );
	player endon( "killed_player" );
	player waittill( "disconnect" );
	modelOrigin = self.origin;
	self Delete();
	PlayFX( getfx( "hider_killed" ), modelOrigin );
}

attachModel( player )
{
	player endon( "disconnect" );
	player endon( "killed_player" );
	player endon( "death" );
	self endon( "death" );
	for( ;; )
	{
		wait (0.01);
		if( self.origin != player.origin )
		{
			self MoveTo( player.origin, 0.1 );
		}
	}
}

hiderHudCreate()
{
	if( !IsDefined( self.modelColumn1_a ) )
	{
		self.modelColumn1_a = NewClientHudElem( self );
		self.modelColumn1_a hiderHudLineCreate( -64, 336, 128, "right" );
		self.modelColumn1_a SetText( &"HIDEANDSEEK_HIDER_CONTROL_A_1" );
	}
	if( !IsDefined( self.modelColumn1_b ) )
	{
		self.modelColumn1_b = NewClientHudElem( self );
		self.modelColumn1_b hiderHudLineCreate( -64, 336, 128, "right", -64 + 24  );
		self.modelColumn1_b SetText( &"HIDEANDSEEK_HIDER_CONTROL_A_2" );
	}
	if( !IsDefined( self.modelColumn2 ) )
	{
		self.modelColumn2 = NewClientHudElem( self );
		self.modelColumn2 hiderHudLineCreate( 0, 128, 128, "center" );
		self.modelColumn2 SetText( &"HIDEANDSEEK_HIDER_CONTROL_B" );
	}
	if( !IsDefined( self.modelColumn3 ) )
	{
		self.modelColumn3 = NewClientHudElem( self );
		self.modelColumn3 hiderHudLineCreate( 64, 336, 128, "left" );
		self.modelColumn3 SetText( &"HIDEANDSEEK_HIDER_CONTROL_C" );
	}
	if( !IsDefined( self.modelNameHUD ) && level.DISPLAY_MODELNAME )
	{
		self.modelNameHUD = NewClientHudElem( self );
		self.modelNameHUD hiderHudLineCreate( 0, 336, 128, "center", -64 - 24 );
	}
	self thread hideHudDestroy();
}

hiderHudLineCreate( x, height, width, xAlign, yOverwrite )
{
	if( !IsDefined( yOverwrite ) )
	{
		yOverwrite = -64;
	}
	self.archived = false;
	self.x = x;
	self.sort = 1;
	self.font = "objective";
	self.foreground = true;
	self.y = yOverwrite;
	self.fontscale = 2;

	self.horzAlign = "center";
	self.vertAlign = "bottom";
	self.alignX = xAlign;
	self.alignY = "middle";
}

hideHudDestroy( skipWait )
{
	if( !IsDefined( skipWait ) )
	{
		self waittill_any( "death", "disconnect" );
	}
	if( IsDefined( self.modelColumn1_a ) )
	{
		self.modelColumn1_a Destroy();
	}
	if( IsDefined( self.modelColumn1_b ) )
	{
		self.modelColumn1_b Destroy();
	}
	if( IsDefined( self.modelColumn2 ) )
	{
		self.modelColumn2 Destroy();
	}
	if( IsDefined( self.modelColumn3 ) )
	{
		self.modelColumn3 Destroy();
	}
	if( IsDefined( self.modelNameHUD ) )
	{
		self.modelNameHUD Destroy();
	}
}

hideTimerDisplayOnGameEnd( timerDisplay )
{
	level waittill( "game_ended" );
	if( IsDefined( timerDisplay ) )
	{
		timerDisplay.alpha = 0;
		waittillframeend;
		timerDisplay Destroy();
	}
}

giveCustomLoadout( takeAllWeapons, alreadySpawned )
{
	chooseRandomBody = false;
	if( !IsDefined( alreadySpawned ) || !alreadySpawned )
	{
		chooseRandomBody = true;
	}
	self maps\mp\gametypes\_wager::setupBlankRandomPlayer( takeAllWeapons, chooseRandomBody );
	self DisableWeaponCycling();
	if( !IsDefined( self.gunProgress ) )
	{
		self.gunProgress = 0;
	}
	if( self.pers[ "team" ] == game[ "defenders" ] )
	{
		return "none";
	}
	currentWeapon = "python_speed_mp";
	self GiveWeapon( currentWeapon );
	self SwitchToWeapon( currentWeapon );
	self GiveWeapon( "knife_mp" );
	if( !IsDefined( alreadySpawned ) || !alreadySpawned )
	{
		self SetSpawnWeapon( currentWeapon );
	}
	if( IsDefined( takeAllWeapons ) && !takeAllWeapons )
	{
		self thread takeOldWeapons( currentWeapon );
	}
	else
	{
		self EnableWeaponCycling();
	}
	return currentWeapon;
}

takeOldWeapons( currentWeapon )
{
	self endon( "disconnect" );
	self endon( "death" );
	for( ;; )
	{
		self waittill( "weapon_change", newWeapon );
		if( newWeapon != "none" )
		{
			break;
		}
	}
	weaponsList = self GetWeaponsList();
	for( i = 0; i < weaponsList.size; i++ )
	{
		if( ( weaponsList[i] != currentWeapon ) && ( weaponsList[i] != "knife_mp" ) )
		{
			self TakeWeapon( weaponsList[i] );
		}
	}
	self EnableWeaponCycling();
}

infiniteAmmo()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "stop_ammo" );
	for( ;; )
	{
		wait ( 0.1 );
		weapon = self GetCurrentWeapon();
		if( IsDefined( weapon ) )
		{
			self GiveMaxAmmo( weapon );
		}
	}
}

damageOnFire()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	while( 1 )
	{
		self waittill ( "weapon_fired" );
		self DoDamage( 10, self.origin, self );
		wait ( 0.05 );
	}
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connected", player );
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
	}
}

onSpawnPlayerUnified()
{
	maps\mp\gametypes\_spawning::onSpawnPlayer_Unified();
}

onSpawnPlayer()
{
	pixbeginevent( "HNS:onSpawnPlayer" );
	self.usingObj = undefined;
	if( level.inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + self.pers[ "team" ] + "_start" );
		if( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_sab_spawn_" + self.pers[ "team" ] + "_start" );
		}
		if( !spawnPoints.size )
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
	self Spawn( spawnPoint.origin, spawnPoint.angles, "tdm" );
	pixendevent();
}

onJoinedTeam()
{
	self endon( "disconnect" );
	for(;;)
	{
		self waittill( "joined_team" );
		if( self.pers[ "team" ] == game[ "defenders" ] )
		{
			self SetClientDvars(
			"cg_thirdPerson", "1",
			"cg_thirdPersonAngle", "360",
			"cg_thirdPersonRange", "200" );
		}
		else
		{
			self SetClientDvars(
			"cg_thirdPerson", "0" );
		}
	}
}

hns_playerSpawnedCB()
{
	level notify ( "spawned_player" );
}

hns_endGame( winningTeam, endReasonText )
{
	if( IsDefined( winningTeam ) )
	{
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );
	}
	thread maps\mp\gametypes\_globallogic::endGame( winningTeam, endReasonText );
}

hns_endGameWithKillcam( winningTeam, endReasonText )
{
	level thread maps\mp\gametypes\_killcam::startLastKillcam();
	hns_endGame( winningTeam, endReasonText );
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon ( "game_ended" );
	for(;;)
	{
		self waittill( "spawned_player" );

		wait ( 1 );
		if( self.pers[ "team" ] == game[ "defenders" ] )
		{
			self makeHider();
			self SetClientDvars(
			"cg_thirdPerson", "1",
			"cg_thirdPersonAngle", "360",
			"cg_thirdPersonRange", "200" );
		}
		else
		{
			self makeSeeker();
			self SetClientDvars(
			"cg_thirdPerson", "0" );
		}
	}
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	thread checkAllowSpectating();
	if( IsDefined( self.pers[ "myprop" ] ) )
	{
		modelOrigin = self.pers[ "myprop" ].origin;
		self.pers[ "myprop" ] Delete();
		PlayFX( getfx( "hider_killed" ), modelOrigin );
	}
	if( sMeansOfDeath == "MOD_SUICIDE" )
	{
		return;
	}
	if( IsDefined( attacker ) && IsPlayer( attacker ) )
	{
		if( attacker == self )
		{
			return;
		}
	}
}

onDeadEvent( team )
{
	if( team == "all" )
	{
		hns_endGameWithKillcam( game[ "defenders" ], game[ "strings" ][game[ "attackers" ]+"_eliminated" ] );
	}
	else if( team == game[ "attackers" ] )
	{
		hns_endGameWithKillcam( game[ "defenders" ], game[ "strings" ][game[ "attackers" ]+"_eliminated" ] );
	}
	else if( team == game[ "defenders" ] )
	{
		hns_endGameWithKillcam( game[ "attackers" ], game[ "strings" ][game[ "defenders" ]+"_eliminated" ] );
	}
}

onTimeLimit()
{
	if( level.teamBased )
	{
		hns_endGame( game[ "defenders" ], game[ "strings" ][ "time_limit_reached" ] );
	}
	else
	{
		hns_endGame( undefined, game[ "strings" ][ "time_limit_reached" ] );
	}
}

onRoundSwitch()
{
	if( !IsDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = false;
	}
	if( game[ "teamScores" ][ "allies" ] == level.scorelimit - 1 && game[ "teamScores" ][ "axis" ] == level.scorelimit - 1 )
	{
		level.halftimeType = "overtime";
	}
	else
	{
		level.halftimeType = "halftime";
	}
	game[ "switchedsides" ] = !game[ "switchedsides" ];
}

onEndGame( winningTeam )
{
	array_thread( level.players, ::hideHudDestroy, true );
	if( IsDefined( winningTeam ) && ( winningTeam == "allies" || winningTeam == "axis" ) )
	{
		[[ level._setTeamScore ]]( winningTeam, [[ level._getTeamScore ]]( winningTeam ) + 1 );
	}
}

onRoundEndGame( roundWinner )
{
	if( game[ "roundswon" ][ "allies" ] == game[ "roundswon" ][ "axis" ] )
	{
		winner = "tie";
	}
	else if( game[ "roundswon" ][ "axis" ] > game[ "roundswon" ][ "allies" ] )
	{
		winner = "axis";
	}
	else
	{
		winner = "allies";
	}
	return winner;
}

onOneLeftEvent( team )
{
	warnLastPlayer( team );
}

warnLastPlayer( team )
{
	if( !IsDefined( level.warnedLastPlayer ) )
	{
		level.warnedLastPlayer = [];
	}
	if( IsDefined( level.warnedLastPlayer[ team ] ) )
	{
		return;
	}
	level.warnedLastPlayer[ team ] = true;
	players = level.players;
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		if( IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team && IsDefined( player.pers[ "class" ] ) )
		{
			if( player.sessionstate == "playing" && !player.afk )
			{
				break;
			}
		}
	}
	if( i == players.size )
	{
		return;
	}
	players[ i ] thread giveLastAttackerWarning();
}

giveLastAttackerWarning()
{
	self endon( "death" );
	self endon( "disconnect" );
	fullHealthTime = 0;
	interval = .05;
	while( 1 )
	{
		if( self.health != self.maxhealth )
		{
			fullHealthTime = 0;
		}
		else
		{
			fullHealthTime += interval;
		}
		wait ( interval );
		if( self.health == self.maxhealth && fullHealthTime >= 3 )
		{
			break;
		}
	}
	self maps\mp\gametypes\_globallogic_audio::leaderDialogOnPlayer( "last_one" );
	self playlocalsound ( "mus_last_stand" );
	self maps\mp\gametypes\_missions::lastManSD();
	self.lastManSD = true;
}

monitorKeyPress()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	self endon( "death" );
	level endon( "game_ended" );
	usableModelsKeys = GetArrayKeys( level.usableModels );

	self hiderHudCreate();

	minZoom = 125;
	maxZoom = 525;
	zoomChangeRate = 5;
	self Hide();

	self.pers[ "myprop" ].rotateYaw_attack = SpawnStruct();
	self.pers[ "myprop" ].rotateYaw_attack.value = 0;
	self.pers[ "myprop" ].rotateYaw_attack.check = ::attackCheck;
	self.pers[ "myprop" ].rotateYaw_attack.max = -50;
	self.pers[ "myprop" ].rotateYaw_attack.change_rate = 1;
	self.pers[ "myprop" ].rotateYaw_attack.reset_rate = 50;
	self.pers[ "myprop" ].rotateYaw_ads = SpawnStruct();
	self.pers[ "myprop" ].rotateYaw_ads.value = 0;
	self.pers[ "myprop" ].rotateYaw_ads.check = ::adsCheck;
	self.pers[ "myprop" ].rotateYaw_ads.max = 50;
	self.pers[ "myprop" ].rotateYaw_ads.change_rate = 1;
	self.pers[ "myprop" ].rotateYaw_ads.reset_rate = 50;
	for(;;)
	{
		wait ( 0.05 );







		if( self FragButtonPressed() && IsDefined( self.pers[ "myprop" ] ) )
		{
			self.pers[ "myprop" ].indexKey = self.pers[ "myprop" ].indexKey + 1;
			PrintLn( "HNS INDEX: " + self.pers[ "myprop" ].indexKey + "   MAX POS: " + level.MAX_USUABLE_MODELS );
			if( self.pers[ "myprop" ].indexKey >= level.MAX_USUABLE_MODELS || self.pers[ "myprop" ].indexKey < 0 )
			{
				self.pers[ "myprop" ].indexKey = 0;
			}
			model = level.usableModels[ usableModelsKeys[ self.pers[ "myprop" ].indexKey ] ];
			self.modelNameHUD SetText( model );
			self.pers[ "myprop" ] SetModel( model );
			self.pers[ "myprop" ] NotSolid();
		}
		if( self SecondaryOffhandButtonPressed() && IsDefined( self.pers[ "myprop" ] ) )
		{
			self.pers[ "myprop" ].indexKey = self.pers[ "myprop" ].indexKey - 1;
			PrintLn( "HNS INDEX: " + self.pers[ "myprop" ].indexKey + "   MAX POS: " + level.MAX_USUABLE_MODELS );
			if( self.pers[ "myprop" ].indexKey >= level.MAX_USUABLE_MODELS || self.pers[ "myprop" ].indexKey < 0 )
			{
				self.pers[ "myprop" ].indexKey = 0;
			}
			model = level.usableModels[ usableModelsKeys[ self.pers[ "myprop" ].indexKey ] ];
			self.modelNameHUD SetText( model );
			self.pers[ "myprop" ] SetModel( model );
			self.pers[ "myprop" ] NotSolid();
		}

		if( self ActionSlotTwoButtonPressed() )
		{
			if( GetDvarInt( "cg_thirdPersonRange" ) > minZoom )
			{
				self SetClientDvar( "cg_thirdPersonRange", GetDvarInt( "cg_thirdPersonRange" ) - zoomChangeRate );
			}
		}
		if( self ActionSlotFourButtonPressed() )
		{
			if( GetDvarInt( "cg_thirdPersonRange" ) < maxZoom )
			{
				self SetClientDvar( "cg_thirdPersonRange", GetDvarInt( "cg_thirdPersonRange" ) + zoomChangeRate );
			}
		}

		self buttonHeldCheck( self.pers[ "myprop" ].rotateYaw_attack );
		self buttonHeldCheck( self.pers[ "myprop" ].rotateYaw_ads );
		self.pers[ "myprop" ] RotateYaw( self.pers[ "myprop" ].rotateYaw_ads.value + self.pers[ "myprop" ].rotateYaw_attack.value, 0.5 );
	}
}

attackCheck()
{
	return ( self AttackButtonPressed() );
}

adsCheck()
{
	return ( self AdsButtonPressed() );
}

buttonHeldCheck( struct )
{
	self endon ( "disconnect" );
	self endon ( "death" );
	if( [[ struct.check ]]() )
	{
		if( struct.max > 0 )
		{
			struct.value += struct.change_rate;
		}
		else
		{
			struct.value -= struct.change_rate;
		}
	}
	else if( struct.value != 0 )
	{
		if( struct.value > 0 )
		{
			struct.value -= struct.reset_rate;
		}
		else
		{
			struct.value += struct.reset_rate;
		}
		if( abs( struct.value ) < struct.reset_rate )
		{
			struct.value = 0;
		}
	}
	if( struct.max > 0 )
	{
		if( struct.value > struct.max )
		{
			struct.value = struct.max;
		}
	}
	else
	{
		if( struct.value < struct.max )
		{
			struct.value = struct.max;
		}
	}
}

onPrecacheGameModels()
{
	precacheLevelModels();
	if( IsDefined( level.availableModels ) && level.availableModels.size > 0 )
	{
		level.availableModels = array_randomize( level.availableModels );
		if( level.availableModels.size < level.MAX_USUABLE_MODELS )
		{
			level.MAX_USUABLE_MODELS = level.availableModels.size;
		}
		availableModelsKeys = GetArrayKeys( level.availableModels );
		if( !IsDefined( level.usableModels ) )
		{
			level.usableModels = [];
		}
		for( x = 0 ; x < level.availableModels.size ; x++ )
		{
			PreCacheModel( level.availableModels[ availableModelsKeys[ x ] ] );
			level.usableModels[ level.availableModels[ availableModelsKeys[ x ] ] ] = level.availableModels[ availableModelsKeys[ x ] ];
			if( level.usableModels.size >= level.MAX_USUABLE_MODELS )
			{
				return;
			}
		}
	}
}

addModel( model )
{
	if( !IsDefined( level.availableModels ) )
	{
		level.availableModels = [];
	}

	if( IsDefined( level.collMapModels ) && IsDefined( level.collMapModels[ model ] ) )
	{

		return;
	}
	if( !IsDefined( level.availableModels[ model ] ) )
	{
		level.availableModels[ model ] = model;
	}
}

precacheLevelModels()
{
	if( IsDefined( level.force_hns_models ) )
	{
		[[ level.force_hns_models ]]();
		return;
	}
	switch( GetDvar( "mapname" ) )
	{
		case "mp_array":
		{
			mpArrayPrecache();
		} break;
		case "mp_berlinwall2":
		{
			mpBerlinwall2Precache();
		} break;
		case "mp_cairo":
		{
			mpCairoPrecache();
		} break;
		case "mp_cosmodrome":
		{
			mpCosmodromePrecache();
		} break;
		case "mp_cracked":
		{
			mpCrackedPrecache();
		} break;
		case "mp_crisis":
		{
			mpCrisisPrecache();
		} break;
		case "mp_discovery":
		{
			mpDiscoveryPrecache();
		} break;
		case "mp_duga":
		{
			mpDugaPrecache();
		} break;
		case "mp_firingrange":
		{
			mpFiringrangePrecache();
		} break;
		case "mp_gridlock":
		{
			mpGridlockPrecache();
		} break;
		case "mp_hanoi":
		{
			mpHanoiPrecache();
		} break;
		case "mp_havoc":
		{
			mpHavocPrecache();
		} break;
		case "mp_hotel":
		{
			mpHotelPrecache();
		} break;
		case "mp_kowloon":
		{
			mpKowloonPrecache();
		} break;
		case "mp_mountain":
		{
			mpMountainPrecache();
		} break;
		case "mp_nuked":
		{
			mpNukedPrecache();
		} break;
		case "mp_outskirts":
		{
			mpOutskirtsPrecache();
		} break;
		case "mp_radiation":
		{
			mpRadiationPrecache();
		} break;
		case "mp_russianbase":
		{
			mpRussianbasePrecache();
		} break;
		case "mp_stadium":
		{
			mpStadiumPrecache();
		} break;
		case "mp_villa":
		{
			mpVillaPrecache();
		} break;
		case "mp_zoo":
		{
			mpZooPrecache();
		} break;
	}
}

addCollMapModel( model )
{
	if( !IsDefined( level.collMapModels ) )
	{
		level.collMapModels = [];
	}
	level.collMapModels[ model ] = model;
}

mapSupport()
{
	if( IsDefined( level.force_hns_support ) && level.force_hns_support )
	{
		return true;
	}
	switch( ToLower( GetDvar( "mapname" ) ) )
	{
		case "mp_array":
		case "mp_berlinwall2":
		case "mp_cairo":
		case "mp_cosmodrome":
		case "mp_cracked":
		case "mp_crisis":
		case "mp_discovery":
		case "mp_duga":
		case "mp_firingrange":
		case "mp_gridlock":
		case "mp_hanoi":
		case "mp_havoc":
		case "mp_hotel":
		case "mp_kowloon":
		case "mp_mountain":
		case "mp_nuked":
		case "mp_outskirts":
		case "mp_radiation":
		case "mp_russianbase":
		case "mp_stadium":
		case "mp_villa":
		case "mp_zoo":
		{
			return true;
		}
	}
	return false;
}

precacheSlide( image, text )
{
	PreCacheShader( image );
	PreCacheString( text );
}

addSlide( image, text )
{
	if( !IsDefined( level.hns_slideshow ) )
	{
		level.hns_slideshow = [];
	}

	temp = SpawnStruct();
	temp.image = image;
	temp.text = text;
	level.hns_slideshow = array_add( level.hns_slideshow, temp );
}

playSlides()
{
	level endon ( "SeekingHasBegun" );
	thread destroySlides();
	level.hns_slideshow_image = NewTeamHudElem( game[ "attackers" ] );
	level.hns_slideshow_image.sort = -1;
	level.hns_slideshow_image.horzAlign = "center";
	level.hns_slideshow_image.vertAlign = "middle";
	level.hns_slideshow_image.alignX = "center";
	level.hns_slideshow_image.alignY = "middle";
	level.hns_slideshow_image.alpha = 0;
	level.hns_slideshow_text = NewTeamHudElem( game[ "attackers" ] );
	level.hns_slideshow_text.sort = -1;
	level.hns_slideshow_text.horzAlign = "center";
	level.hns_slideshow_text.vertAlign = "bottom";
	level.hns_slideshow_text.alignX = "center";
	level.hns_slideshow_text.alignY = "bottom";
	level.hns_slideshow_text.alpha = 0;
	level.hns_slideshow_text.y = -64;
	level.hns_slideshow_text.fontscale = 1.5;
	while( 1 )
	{
		for( x = 0 ; x < level.hns_slideshow.size ; x++ )
		{
			level.hns_slideshow_text SetText( level.hns_slideshow[ x ].text );
			level.hns_slideshow_image SetShader( level.hns_slideshow[ x ].image, 512, 256 );
			level.hns_slideshow_text FadeOverTime( 0.75 );
			level.hns_slideshow_text.alpha = 1;
			level.hns_slideshow_image FadeOverTime( 0.75 );
			level.hns_slideshow_image.alpha = 1;
			wait ( 5 );
			level.hns_slideshow_text FadeOverTime( 0.75 );
			level.hns_slideshow_text.alpha = 0;
			level.hns_slideshow_image FadeOverTime( 0.75 );
			level.hns_slideshow_image.alpha = 0;
			wait ( 0.74 );
		}
		wait ( 0.05 );
	}
}

destroySlides()
{
	level waittill ( "SeekingHasBegun" );
	if( IsDefined( level.hns_slideshow_image ) )
	{
		level.hns_slideshow_image Destroy();
	}
	if( IsDefined( level.hns_slideshow_text ) )
	{
		level.hns_slideshow_text Destroy();
	}
}

getHiders()
{
	hiders = [];
	for( x = 0 ; x < level.players.size ; x++ )
	{
		player = level.players[ x ];
		if( IsDefined( player ) && IsDefined( player.pers ) && IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "axis" && player.sessionstate == "playing" )
		{
			hiders[ hiders.size ] = player;
		}
	}
	return hiders;
}

getSeekers()
{
	seekers = [];
	for( x = 0 ; x < level.players.size ; x++ )
	{
		player = level.players[ x ];
		if( IsDefined( player ) && IsDefined( player.pers ) && IsDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == "allies" && player.sessionstate == "playing"  )
		{
			seekers[ seekers.size ] = player;
		}
	}
	return seekers;
}