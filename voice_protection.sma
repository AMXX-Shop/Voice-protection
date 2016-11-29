#include <amxmodx>
#include <csstats>
#include <reapi>

#pragma semicolon 1

#define USE_IMMUNITY ADMIN_BAN // comment out this line if you don't want use immunity
#define USE_CHAT_PROTECTION // comment out this line if you don't want use chat protection
#define USE_NOTIFICATIONS // comment out this line if you don't want use notifications

const MIN_FRAGS = 10; // minimum number of frags for unlock client (default: 10)
const Float:GET_STATS_DELAY = 1.0;

#if defined USE_NOTIFICATIONS
new g_HudSyncObj;
#endif

new g_Frags[MAX_CLIENTS + 1];

public plugin_init() {
	register_plugin("Voice protection", "0.3", "AMXX.Shop");
	register_dictionary("voice_protection.txt");
	if(!has_vtc()) {
		set_fail_state("VTC is required for plugin work!");
	}
	RegisterHookChain(RG_CBasePlayer_Killed, "RGCBasePlayerKilledPost", true);
	#if defined USE_CHAT_PROTECTION
	register_clcmd("say", "CmdSay");
	register_clcmd("say_team", "CmdSay");
	#endif
	#if defined USE_NOTIFICATIONS
	g_HudSyncObj = CreateHudSyncObj();
	#endif
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
	if(!is_user_connected(Attacker) || g_Frags[Attacker] >= MIN_FRAGS || Victim == Attacker) {
		return;
	}
	if(++g_Frags[Attacker] == MIN_FRAGS) {
		VTC_UnmuteClient(Attacker);
	}
	#if defined USE_NOTIFICATIONS
	else {
		set_hudmessage(128, 128, 128, _, 0.25, _, _, 10.0, _, _, -1);
		ShowSyncHudMsg(Attacker, g_HudSyncObj, "%L^n%L", Attacker, "VP_TO_BEGIN", Attacker, "VP_NEED_YET", MIN_FRAGS - g_Frags[Attacker]);
	}
	#endif
}

#if defined USE_CHAT_PROTECTION
public CmdSay(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	new Args[10];
	read_args(Args, charsmax(Args));
	remove_quotes(Args);
	if(Args[0] == '/') {
		return PLUGIN_HANDLED_MAIN;
	}
	if(g_Frags[id] < MIN_FRAGS) {
		client_print(id, print_chat, "%L %L", id, "VP_TO_BEGIN", id, "VP_NEED_YET", MIN_FRAGS - g_Frags[id]);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
#endif
