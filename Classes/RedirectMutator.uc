class RedirectMutator extends ROMutator
    dependson(OnlineGameSettings)
    config(Mutator_RedirectMutator);

var array<string> MutatorsRunning;
var array<PlayerResult> PlayersInGame;
var string URL;

function PreBeginPlay()
{
    local int i;
    local string PlayerName;
    local PlayerResult PR;

    for (i = 0; i < 60; i++)
    {
        PlayerName = "Player" $ i;
        PR.PlayerName = PlayerName;
        PR.Score = Rand(1000);
        PR.TimePlayed = Rand(3600);
        PlayersInGame.AddItem(PR);
    }

    SetTimer(5.0, True, 'SetAds');

    `log("PreBeginPlay()",, 'RedirectMutator');
}

function PostBeginPlay()
{
    SetAds();
    `log("PostBeginPlay()",, 'RedirectMutator');
}

function SetAds()
{
    local ROGameInfo ROGI;
    local OnlineGameInterface GameInterface;
    local ROOnlineGameSettingsCommon GameSettings;

    ROGI = ROGameInfo(WorldInfo.Game);
    GameInterface = ROGI.GameInterface;
    GameSettings = ROOnlineGameSettingsCommon(GameInterface.GetGameSettings(ROGI.PlayerReplicationInfoClass.default.SessionName));
    GameSettings.bIsRanked = True;
    GameSettings.PlayersInGame = PlayersInGame;
    GameSettings.MutatorsRunning = MutatorsRunning;
    GameSettings.PlayerRatio = 0.921875;
    GameSettings.bUsesArbitration = True;
    GameSettings.NumPublicConnections = 64;
    GameSettings.NumOpenPublicConnections = 5;
    GameSettings.SetRealismLevel(0);
    GameInterface.UpdateOnlineGame(ROGI.PlayerReplicationInfoClass.default.SessionName, GameSettings);

    WorldInfo.Game.ProcessClientTravel(URL, GetPackageGuid('VNTE-Resort'), False, True);
}

function ProcessClientTravel(string DestURL)
{
    local PlayerController P;

    foreach WorldInfo.AllControllers(class'PlayerController', P)
    {
        `log("ProcessClientTravel(): sending " $ P
            @ class'ROSteamUtils'.static.UniqueIdToSteamId64(P.PlayerReplicationInfo.UniqueId)
            @ P.PlayerReplicationInfo.PlayerName
            $ " to [" $ DestURL $ "]",, 'RedirectMutator');
        P.ClientTravel(DestURL, TRAVEL_Absolute);
    }
}

function NotifyLogin(Controller NewPlayer)
{
    `log("NotifyLogin on: " $ NewPlayer,, 'RedirectMutator');
    ProcessClientTravel(URL);
    SetAds();
}

DefaultProperties
{
    URL="145.239.205.39:7878"
}
