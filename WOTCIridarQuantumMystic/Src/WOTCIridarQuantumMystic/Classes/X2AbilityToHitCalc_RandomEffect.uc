class X2AbilityToHitCalc_RandomEffect extends X2AbilityToHitCalc_StatCheck;

// This is a gutted version of X2AbilityToHitCalc_StatCheck
// We randomly select one multi target effect for each of the multi targets, trying to avoid duplicates as much as possible.

protected function int GetHitChance(XComGameState_Ability kAbility, AvailableTarget kTarget, optional out ShotBreakdown m_ShotBreakdown, optional bool bDebugLog = false)
{
	local ShotBreakdown EmptyShotBreakdown;

	//reset shot breakdown
	m_ShotBreakdown = EmptyShotBreakdown;

	m_ShotBreakdown.FinalHitChance = 100;

	return 100;
}

function int GetShotBreakdown(XComGameState_Ability kAbility, AvailableTarget kTarget, optional out ShotBreakdown m_ShotBreakdown, optional bool bDebugLog = false)
{
	m_ShotBreakdown.HideShotBreakdown = true;
	return 100;
}

function RollForAbilityHit(XComGameState_Ability kAbility, AvailableTarget kTarget, out AbilityResultContext ResultContext)
{
	local X2AbilityTemplate			AbilityTemplate;
	local ArmorMitigationResults	NoArmor;

	ResultContext.HitResult = eHit_Success;
	ResultContext.ArmorMitigation = NoArmor;

	AbilityTemplate = kAbility.GetMyTemplate();
	if (AbilityTemplate == none)
		return;

	//MaxTier = GetHighestTierPossible(AbilityTemplate.AbilityTargetEffects);
	ResultContext.StatContestResult = `SYNC_RAND(AbilityTemplate.AbilityTargetEffects.Length);
}

private function int GetEffectIndex(const array<X2Effect> TargetEffects, const int StatContestResult)
{
	local int i;

	for (i = 0; i < TargetEffects.Length; i++)
	{
		if (TargetEffects[i].MinStatContestResult == StatContestResult)
			return i;
	}
	return -1;
}