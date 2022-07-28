
void LoadDefaultMapLoaders()
{
	printf("############ GAMEMODE " + sv_gamemode);
	RegisterFileExtensionScript("Scripts/MapLoaders/LoadPNGMap.as", "png");
	RegisterFileExtensionScript("Scripts/MapLoaders/GenerateMapMakerGen.as", "kaggen.cfg");
}
