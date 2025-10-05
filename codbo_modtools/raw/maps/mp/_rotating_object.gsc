#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	rotating_objects = GetEntArray("rotating_object", "targetname");
	
	if(IsDefined(rotating_objects))
	{
		set_dvar_int_if_unset( "scr_rotating_objects_secs", 12 );
		
		if(!IsDefined(GetDvar( #"scr_rotating_objects_secs")))
		{
			PrintLn("scr_rotating_objects_secs is undefined");
		}	
	}
} 
  
