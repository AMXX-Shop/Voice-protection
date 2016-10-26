#include <amxmodx>
#include <csstats>
#include <reapi>

#pragma semicolon 1

#define USE_IMMUNITY ADMIN_BAN // comment out this line if you don't want use immunity

const MIN_FRAGS = 10;
const Float:GET_STATS_DELAY = 1.0;

new g_Frags[MAX_CLIENTS + 1];

public plugin_init() {
	register_plugin("Voice protection", "0.1", "AMXX.Shop");
	if(!has_vtc()) {
		set_fail_state("VTC is required for plugin work!");
	}
	RegisterHookChain(RG_CBasePlayer_Killed, "RGCBasePlayerKilledPost", 1);
}

public client_putinserver(id) {
	if(is_user_bot(id) || is_user_hltv(id)) {
		return;
	}
	#if defined USE_IMMUNITY
	if(get_user_flags(id) & USE_IMMUNITY) {
		g_Frags[id] = MIN_FRAGS;
	} else {
		set_task(GET_STATS_DELAY, "GetStats", id);
	}
	#else
	set_task(GET_STATS_DELAY, "GetStats", id);
	#endif
}

public client_disconnect(id) {
	remove_task(id);
}

public GetStats(const id) {
	new Stats[8], BodyHits[8];
	get_user_stats(id, Stats, BodyHits);
	if((g_Frags[id] = Stats[0]) < MIN_FRAGS) {
		VTC_MuteClient(id);
	}
}

public RGCBasePlayerKilledPost(const Victim, const Attacker) {
	if(g_Frags[Attacker] >= MIN_FRAGS) {
		return;
	}
	if(++g_Frags[Attacker] == MIN_FRAGS) {
		VTC_UnmuteClient(Attacker);
	}
}