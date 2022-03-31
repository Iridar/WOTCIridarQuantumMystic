class X2EventListener_QuantumMystic extends X2EventListener;

var localized string strQuantumStaffWeaponCat;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ListenerTemplate());

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