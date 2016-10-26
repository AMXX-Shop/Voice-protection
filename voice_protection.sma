#include <amxmodx>
#include <csstats>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon 1

#define USE_IMMUNITY ADMIN_BAN // comment out this line if you don't want use immunity

const MIN_FRAGS = 10;
const Float:GET_STATS_DELAY = 1.0;

new g_Frags[33];

public plugin_init() {
	register_plugin("Voice protection", "0.1", "AMXX.Shop");
	register_forward(FM_Voice_SetClientListening, "FMVoiceSetClientListeningPre");
	RegisterHam(Ham_Killed, "player", "HamKilledPlayerPost", 1);
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
	g_Frags[id] = Stats[0];
}

public FMVoiceSetClientListeningPre(const Receiver, const Sender) {
	if(g_Frags[Sender] < MIN_FRAGS) {
		engfunc(EngFunc_SetClientListening, Receiver, Sender, false);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public HamKilledPlayerPost(const Victim, const Attacker) {
	g_Frags[Attacker]++;
}