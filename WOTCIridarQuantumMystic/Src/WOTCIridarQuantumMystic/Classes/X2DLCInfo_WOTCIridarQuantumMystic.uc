class X2DLCInfo_WOTCIridarQuantumMystic extends X2DownloadableContentInfo;

var localized array<string> WisdomOfChopra;

var config array<name> StartingItemsToAddOnSaveLoad;
var config array<name> AlwaysExcludeAbilities;

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	local X2SoldierClassTemplateManager SoldierMgr;
	local X2SoldierClassTemplate		ClassTemplate;
	local SoldierClassAbilityType		SoldierAbility;
	local X2AbilityTemplateManager		AbilityMgr;
	local array<name>					TemplateNames;
	local name							TemplateName;
	local X2AbilityTemplate				AbilityTemplate;
	local X2AbilityTemplate				QuantumMysticism;
	local X2ItemTemplateManager			ItemMgr;
	local X2WeaponTemplate				WeaponTemplate_CV;
	local X2WeaponTemplate				WeaponTemplate_MG;
	local X2WeaponTemplate				WeaponTemplate_BM;
	local WeaponDamageValue				DamageValue;
	local array<name>					DamageTags;
	local name							DamageTag;
	local X2Effect						NewEffect;
	local X2Effect						Effect;
	local int i;

	SoldierMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ClassTemplate = SoldierMgr.FindSoldierClassTemplate('QuantumMystic');
	if (ClassTemplate == none)
		return;

	if (IsModActive('LongWarOfTheChosen'))
	{
		// For LWOTC add an additional rank.
		ClassTemplate.SoldierRanks.AddItem(ClassTemplate.SoldierRanks[ClassTemplate.SoldierRanks.Length - 1]);
	}
	if (IsModActive('XCOM2RPGOverhaul'))
	{
		// For RPGO, disable the soldier class.
		// Quantum Mysticism will be added directly to Mystic Staves.
		ClassTemplate.NumInForcedDeck = 0;
		ClassTemplate.NumInDeck = 0;
	}
	
	WeaponTemplate_CV = X2WeaponTemplate(ItemMgr.FindItemTemplate('MysticStaff_CV'));
	WeaponTemplate_MG = X2WeaponTemplate(ItemMgr.FindItemTemplate('MysticStaff_MG'));
	WeaponTemplate_BM = X2WeaponTemplate(ItemMgr.FindItemTemplate('MysticStaff_BM'));

	AbilityMgr.GetTemplateNames(TemplateNames);

	// 1. Add all abilities in the game into Quantum Mystic's random ability deck.
	SoldierAbility.ApplyToWeaponSlot = eInvSlot_PrimaryWeapon;

	foreach default.AlwaysExcludeAbilities(TemplateName)
	{
		TemplateNames.RemoveItem(TemplateName);
	}

	foreach TemplateNames(TemplateName)
	{
		AbilityTemplate = AbilityMgr.FindAbilityTemplate(TemplateName);
		if (AbilityTemplate == none ||
			AbilityTemplate.LocFriendlyName == "" ||
			AbilityTemplate.LocHelpText == "" ||
			AbilityTemplate.LocLongDescription == "" ||
			AbilityTemplate.IconImage == "" ||
			AbilityTemplate.ChosenTraitType == 'Summoning' ||
			AbilityTemplate.ChosenTraitType == 'Adversary' ||
			AbilityTemplate.bStationaryWeapon ||
			AbilityTemplate.AbilitySourceName == 'eAbilitySource_Commander' ||
			AbilityTemplate.AbilitySourceName == 'eAbilitySource_Standard' ||
			AbilityTemplate.AbilitySourceName == 'eAbilitySource_Debuff' ||
			/*AbilityTemplate.AbilitySourceName == 'eAbilitySource_Item' || */
			AbilityTemplate.AbilitySourceName == 'eAbilitySource_Debuff' ||
			IsAdditionalAbility(TemplateName, AbilityMgr)||
			HasFocusCost(AbilityTemplate))
			continue;

		// Force the used abilities to always use the same base damage and standard fire animation with the quantum staff	
		WeaponTemplate_CV.SetAnimationNameForAbility(TemplateName, 'FF_Fire');
		WeaponTemplate_MG.SetAnimationNameForAbility(TemplateName, 'FF_Fire');
		WeaponTemplate_BM.SetAnimationNameForAbility(TemplateName, 'FF_Fire');
		
		DamageTags = GetAbilityDamageTags(AbilityTemplate);
		foreach DamageTags(DamageTag)
		{	
			if (WeaponTemplate_CV.ExtraDamage.Find('Tag', DamageTag) != INDEX_NONE)
				continue;

			DamageValue.Tag = DamageTag;

			DamageValue = WeaponTemplate_CV.BaseDamage;
			WeaponTemplate_CV.ExtraDamage.AddItem(DamageValue);

			DamageValue = WeaponTemplate_MG.BaseDamage;
			WeaponTemplate_MG.ExtraDamage.AddItem(DamageValue);

			DamageValue = WeaponTemplate_BM.BaseDamage;
			WeaponTemplate_BM.ExtraDamage.AddItem(DamageValue);
		}
		SoldierAbility.AbilityName = TemplateName;
		ClassTemplate.RandomAbilityDecks[0].Abilities.AddItem(SoldierAbility);
	}

	// 2. Add random effects from random abilities into Quntum Mysticism.
	QuantumMysticism = AbilityMgr.FindAbilityTemplate('QuantumMysticism');
	i = 0;

	while (i < 100 && TemplateNames.Length > 0)
	{
		TemplateName = TemplateNames[`SYNC_RAND_STATIC(TemplateNames.Length)];
		AbilityTemplate = AbilityMgr.FindAbilityTemplate(TemplateName);
		if (AbilityTemplate != none)
		{
			if (AbilityTemplate.AbilityTargetEffects.Length == 0)
				continue;

			Effect = AbilityTemplate.AbilityTargetEffects[`SYNC_RAND_STATIC(AbilityTemplate.AbilityTargetEffects.Length)];
			if (Effect.TargetConditions.Length != 0)
				continue;

			NewEffect = new class<X2Effect>(class'XComEngine'.static.GetClassByName(Effect.Class.Name))(Effect);		
			NewEffect.MinStatContestResult = i;
			NewEffect.MaxStatContestResult = i;
			QuantumMysticism.AddTargetEffect(NewEffect);
			i++;

			//`LOG("Adding Effect:" @ NewEffect.Class.Name,, 'IRITEST');
		}

		TemplateNames.RemoveItem(TemplateName);
	}

	AddGTSUnlockTemplate('IRI_QuantumMystic_GTS');
}

static private function AddGTSUnlockTemplate(name UnlockTemplateName)
{
    local X2StrategyElementTemplateManager  TechMgr;
    local X2FacilityTemplate                Template;
    local array<X2DataTemplate>             DifficultyVariants;
    local X2DataTemplate                    DifficultyVariant;

    TechMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

    TechMgr.FindDataTemplateAllDifficulties('OfficerTrainingSchool', DifficultyVariants);

    foreach DifficultyVariants(DifficultyVariant)
    {
        Template = X2FacilityTemplate(DifficultyVariant);
        if (Template != none)
        {
           Template.SoldierUnlockTemplates.AddItem(UnlockTemplateName);
        }
    }
}

static private function bool HasFocusCost(const X2AbilityTemplate AbilityTemplate)
{
	local X2AbilityCost Cost;

	foreach AbilityTemplate.AbilityCosts(Cost)
	{
		if (X2AbilityCost_Focus(Cost) != none)
			return true;
	}
	return false;
}

static private function bool IsAdditionalAbility(const name TemplateName, X2AbilityTemplateManager AbilityMgr)
{
	local X2DataTemplate DataTemplate;
	local X2AbilityTemplate AbilityTemplate;

	foreach AbilityMgr.IterateTemplates(DataTemplate)
	{
		AbilityTemplate = X2AbilityTemplate(DataTemplate);
		if (AbilityTemplate.AdditionalAbilities.Find(TemplateName) != INDEX_NONE)
		{
			return true;
		}
	}
	return false;
}

static private function array<name> GetAbilityDamageTags(const X2AbilityTemplate AbilityTemplate)
{
	local array<name> DamageTags;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2Effect Effect;

	foreach AbilityTemplate.AbilityShooterEffects(Effect)
	{
		DamageEffect = X2Effect_ApplyWeaponDamage(Effect);
		if (DamageEffect != none)
		{	
			if (DamageEffect.DamageTag != '')
			{
				DamageTags.AddItem(DamageEffect.DamageTag);
			}
		}
	}

	foreach AbilityTemplate.AbilityTargetEffects(Effect)
	{
		DamageEffect = X2Effect_ApplyWeaponDamage(Effect);
		if (DamageEffect != none)
		{	
			if (DamageEffect.DamageTag != '')
			{
				DamageTags.AddItem(DamageEffect.DamageTag);
			}
		}
	}

	foreach AbilityTemplate.AbilityMultiTargetEffects(Effect)
	{
		DamageEffect = X2Effect_ApplyWeaponDamage(Effect);
		if (DamageEffect != none)
		{	
			if (DamageEffect.DamageTag != '')
			{
				DamageTags.AddItem(DamageEffect.DamageTag);
			}
		}
	}

	return DamageTags;
}

static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local XComGameState_Unit		UnitState;
	local array<SkeletalMeshSocket> NewSockets;
	local XComGameState_Item		PrimaryWeapon;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.ObjectID));
	if (UnitState == none)
		return "";

	PrimaryWeapon = UnitState.GetPrimaryWeapon();

	if (PrimaryWeapon != none && PrimaryWeapon.GetWeaponCategory() == 'MysticStaff') // Check for weapon instead of soldier class for the sake of RPGO.
	{
		NewSockets.AddItem(CreateSocket('MysticStaff', 'RHand', 5, 2, 0, 5, -85, 5));
		Pawn.Mesh.AppendSockets(NewSockets, true);
	}
	return "";
}

static private function SkeletalMeshSocket CreateSocket(const name SocketName, const name BoneName, optional const float X, optional const float Y, optional const float Z, optional const float dRoll, optional const float dPitch, optional const float dYaw, optional float ScaleX = 1.0f, optional float ScaleY = 1.0f, optional float ScaleZ = 1.0f)
{
	local SkeletalMeshSocket NewSocket;

	NewSocket = new class'SkeletalMeshSocket';
    NewSocket.SocketName = SocketName;
    NewSocket.BoneName = BoneName;

    NewSocket.RelativeLocation.X = X;
    NewSocket.RelativeLocation.Y = Y;
    NewSocket.RelativeLocation.Z = Z;

    NewSocket.RelativeRotation.Roll = dRoll * DegToUnrRot;
    NewSocket.RelativeRotation.Pitch = dPitch * DegToUnrRot;
    NewSocket.RelativeRotation.Yaw = dYaw * DegToUnrRot;

	NewSocket.RelativeScale.X = ScaleX;
	NewSocket.RelativeScale.Y = ScaleY;
	NewSocket.RelativeScale.Z = ScaleZ;
    
	return NewSocket;
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	if (name(InString) == 'QuantumMysticism')
	{
		OutString = default.WisdomOfChopra[`SYNC_RAND_STATIC(default.WisdomOfChopra.Length)];
		return true;
	}

    return false;
}

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>

static event OnLoadedSavedGame()
{
	local XComGameStateHistory				History;
	local XComGameState						NewGameState;
	local XComGameState_HeadquartersXCom	XComHQ;
	local XComGameState_Item				ItemState;
	local X2ItemTemplate					ItemTemplate;
	local name								TemplateName;
	local X2ItemTemplateManager				ItemMgr;
	local bool								bChange;

	History = `XCOMHISTORY;	
	XComHQ = `XCOMHQ;
	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();	

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("WOTCMoreSparkWeapons: Add Starting Items");
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	//	-------------------------------------------------------------------------
	//	ADD STARTING ITEMS TO HQ INVENTORY

	//	Add an instance of the specified item template into HQ inventory
	foreach default.StartingItemsToAddOnSaveLoad(TemplateName)
	{
		ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);

		//	If the item is not in the HQ Inventory already
		if (ItemTemplate != none && !XComHQ.HasItem(ItemTemplate))
		{
			//	If it's a starting item or if the schematic this item is created by is present in the HQ inventory
			if (ItemTemplate.StartingItem || ItemTemplate.CreatorTemplateName != '' && XComHQ.HasItemByName(ItemTemplate.CreatorTemplateName))
			{	
				ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
				NewGameState.AddStateObject(ItemState);
				XComHQ.AddItemToHQInventory(ItemState);	

				bChange = true;
			}
		}
	}

	if (bChange)
	{
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static final function bool IsModActive(name ModName)
{
    local XComOnlineEventMgr    EventManager;
    local int                   Index;

    EventManager = `ONLINEEVENTMGR;

    for (Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--) 
    {
        if (EventManager.GetDLCNames(Index) == ModName) 
        {
            return true;
        }
    }
    return false;
}