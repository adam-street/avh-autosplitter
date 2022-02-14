state("Apes vs Helium")
{
	byte health: "UnityPlayer.dll", 0x018663C0, 0x430, 0xE8, 0x10, 0x98, 0x10, 0x60, 0x28;
	byte spawner_state: "UnityPlayer.dll", 0x017F9F88, 0X48, 0xB8, 0x8, 0X8, 0X80, 0x64;
	byte level: "UnityPlayer.dll", 0x017F9E80, 0xF8, 0x10, 0xB8, 0x8, 0x8, 0x80, 0x68;
}

startup
{
	var bytes = File.ReadAllBytes(@"Components\ULibrary.bin");
	vars.unity = Assembly.Load(bytes).CreateInstance("ULibrary.Unity");
}

init {
	vars.unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		var _ps = helper.GetClass("Assembly-CSharp", "PauseScript");
		vars.unity.Make<bool>(_ps.Static, _ps["instance"], _ps["gameFinished"]).Name = "gameFinished";
		return true;
	});
	vars.unity.Load(game);
}

update {
	if (!vars.unity.Loaded) return false;
	vars.unity.Watchers.UpdateAll(game);
	current.game_finished = vars.unity.Watchers["gameFinished"].Current;
}

start
{	
	if (current.spawner_state == 0 && current.level == 0 && current.health != 0) {
		return true;
	}
}

split {
	if (current.game_finished) {
		return true;
	}
	return current.level != old.level && current.spawner_state == 2;
}

reset
{
	if (current.level == 0 && old.spawner_state != current.spawner_state && current.spawner_state == 2) {
		return true;
	}
}
