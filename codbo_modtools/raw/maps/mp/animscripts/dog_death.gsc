
#include maps\mp\animscripts\utility;
main()
{
	debug_anim_print("dog_death::main()" );
	self SetAimAnimWeights( 0, 0 );
	self endon("killanimscript");
	if ( isdefined( self.a.nodeath ) )
	{
		assertex( self.a.nodeath, "Nodeath needs to be set to true or undefined." );
		
		
		wait 3;
		return;
	}
	self unlink();
	if ( isdefined( self.enemy ) && isdefined( self.enemy.syncedMeleeTarget ) && self.enemy.syncedMeleeTarget == self )
	{
		self.enemy.syncedMeleeTarget = undefined;
	}
	death_anim = "death_" + getAnimDirection( self.damageyaw );
	
	self animMode( "gravity" );
	debug_anim_print("dog_death::main() - Setting " + death_anim );
	self setanimstate( death_anim );
	self maps\mp\animscripts\shared::DoNoteTracks( "done" );
}