class X2EventListener_QuantumMystic extends X2EventListener;

var localized string strQuantumStaffWeaponCat;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ListenerTemplate());
	Templates.AddItem(Create_StrategicListenerTemplate());

	return Templates;
}

static function CHEventListenerTemplate Create_ListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_QuantumMystic');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('GetLocalizedCategory', OnGetLocalizedCategory, ELD_Immediate, 50);
	

	return Template;
}

static function EventListenerReturn OnGetLocalizedCategory(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local X2WeaponTemplate Template;

	
	Template = X2WeaponTemplate(EventSource);

	if (Tuple == none || Template == none)
		return ELR_NoInterrupt;

	if (Template.WeaponCat == 'MysticStaff')
	{
		Tuple = XComLWTuple(EventData);
		if (Tuple != none)
		{
			Tuple.Data[0].s = default.strQuantumStaffWeaponCat;
		}
	}

	return ELR_NoInterrupt;
}

static function CHEventListenerTemplate Create_StrategicListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_QuantumMystic_Strategy');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OverrideRespecSoldierProjectPoints', OnOverrideRespecSoldierProjectPoints, ELD_Immediate, 50);
	

	return Template;
}

static function EventListenerReturn OnOverrideRespecSoldierProjectPoints(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackObject)
{
    local XComLWTuple Tuple;
    local XComGameState_Unit Unit;

	if (`XCOMHQ.HasSoldierUnlockTemplate('IRI_QuantumMystic_GTS'))
	{
		Tuple = XComLWTuple(EventData);
		Unit = XComGameState_Unit(Tuple.Data[0].o);

		if (Unit != none && Unit.GetSoldierClassTemplateName() == 'QuantumMystic')
		{
			Tuple.Data[1].i = 1; // ProjectPoints
		}
	}

    return ELR_NoInterrupt;
}