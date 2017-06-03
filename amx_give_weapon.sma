#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fun>

public plugin_init( )
{
	register_plugin("amx_give_weapon", "1.0", "Craxor");
	register_concmd( "amx_give_weapon", "_givecmd", ADMIN_KICK, "amx_give_weapon <Name> <weapon_*  Name> <Ammo> <BpAmmo>" );
}

public _givecmd( id, level, cid )
{
	if( !cmd_access( id, level, cid, 4 ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new szArg1[32];
	new szArg2[20];
	new szArg3[5];
	new szArg4[5];

	read_argv( 1, szArg1, charsmax( szArg1 ) );	
	read_argv( 2, szArg2, charsmax( szArg2 ) );
	read_argv( 3, szArg3, charsmax( szArg3 ) );
	read_argv( 4, szArg4, charsmax( szArg4 ) );

	new player = cmd_target( id, szArg1, ~CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ONLY_ALIVE );
	new iWeaponID = get_weaponid( szArg2 );

	if( !player || !iWeaponID )
	{
		return PLUGIN_HANDLED;
	}

	new szWeaponName[20];
	new szAdminName[32]; get_user_name( id, szAdminName, charsmax( szAdminName ) );

	give_user_weapon ( player , iWeaponID, str_to_num( szArg3 ), str_to_num( szArg4 ), szWeaponName, charsmax( szWeaponName ) );
	client_print( player, print_chat, "Admin '%s' give you the weapon: %s", szAdminName, szWeaponName );

	return PLUGIN_HANDLED;
}


give_user_weapon( index , iWeaponTypeID , iClip=0 , iBPAmmo=0 , szWeapon[]="" , maxchars=0 )
{
	if ( !( CSW_P228 <= iWeaponTypeID <= CSW_P90 ) || ( iClip < 0 ) || ( iBPAmmo < 0 ) || !is_user_alive( index ) )
		return -1;
	
	new szWeaponName[ 20 ] , iWeaponEntity , bool:bIsGrenade;
	
	const GrenadeBits = ( ( 1 << CSW_HEGRENADE ) | ( 1 << CSW_FLASHBANG ) | ( 1 << CSW_SMOKEGRENADE ) | ( 1 << CSW_C4 ) );
	
	if ( ( bIsGrenade = bool:!!( GrenadeBits & ( 1 << iWeaponTypeID ) ) ) )
		iClip = clamp( iClip ? iClip : iBPAmmo , 1 );
	
	get_weaponname( iWeaponTypeID , szWeaponName , charsmax( szWeaponName ) );
	
	if ( ( iWeaponEntity = user_has_weapon( index , iWeaponTypeID ) ? find_ent_by_owner( -1 , szWeaponName , index ) : give_item( index , szWeaponName ) ) > 0 )
	{
		if ( iWeaponTypeID != CSW_KNIFE )
		{
			if ( iClip && !bIsGrenade )
				cs_set_weapon_ammo( iWeaponEntity , iClip );
		
			if ( iWeaponTypeID == CSW_C4 ) 
				cs_set_user_plant( index , 1 , 1 );
			else
				cs_set_user_bpammo( index , iWeaponTypeID , bIsGrenade ? iClip : iBPAmmo ); 
		}
		
		if ( maxchars )
			copy( szWeapon , maxchars , szWeaponName[7] );
	}
	
	return iWeaponEntity;
}
