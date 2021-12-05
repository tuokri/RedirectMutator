class RedirectMutator extends ROMutator
    // dependson(OnlineGameSettings)
    config(Mutator_RedirectMutator);

var RedirectMutatorConfig MutConfig;

var array<string> MutatorsRunning;
// var array<PlayerResult> PlayersInGame;

function PreBeginPlay()
{
    /*
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
    */

    super.PreBeginPlay();

    MutConfig = new(self) class'RedirectMutatorConfig';

    SetAds();
    SetTimer(5.0, True, 'SetAds');

    `log("PreBeginPlay()",, 'RedirectMutator');
}

function PostBeginPlay()
{
    super.PostBeginPlay();

    SetAds();
    `log("PostBeginPlay()",, 'RedirectMutator');
}

function InitMutator(string Options, out string ErrorMessage)
{
    local string URLOpt;

    URLOpt = class'GameInfo'.static.ParseOption(Options, "RedirectURL");
    if (URLOpt != "")
    {
        `log("setting RedirectURL to " $ URLOpt,, 'RedirectMutator');
        MutConfig.RedirectURL = URLOpt;
        MutConfig.SaveConfig();
    }

    super.InitMutator(Options, ErrorMessage);
}

// Fake server advertisement data to attract players using quick match.
function SetAds()
{
    local ROGameInfo ROGI;
    local OnlineGameInterface GameInterface;
    local ROOnlineGameSettingsCommon GameSettings;

    ROGI = ROGameInfo(WorldInfo.Game);
    GameInterface = ROGI.GameInterface;
    GameSettings = ROOnlineGameSettingsCommon(GameInterface.GetGameSettings(ROGI.PlayerReplicationInfoClass.default.SessionName));
    GameSettings.bIsRanked = True;
    // GameSettings.PlayersInGame = PlayersInGame;
    GameSettings.MutatorsRunning = MutatorsRunning;
    GameSettings.PlayerRatio = 0.921875;
    GameSettings.bUsesArbitration = True;
    GameSettings.NumPublicConnections = 64;
    GameSettings.NumOpenPublicConnections = 5;
    GameSettings.SetRealismLevel(0);
    GameInterface.UpdateOnlineGame(ROGI.PlayerReplicationInfoClass.default.SessionName, GameSettings);

    // Probably not needed here, but do it anyway to send any possible "stragglers" on their way.
    WorldInfo.Game.ProcessClientTravel(MutConfig.RedirectURL, GetPackageGuid('VNTE-Resort'), False, True);
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
    ProcessClientTravel(MutConfig.RedirectURL);
    SetAds();

    super.NotifyLogin(NewPlayer);
}

DefaultProperties
{
}
