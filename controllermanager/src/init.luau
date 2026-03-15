local Server = require(script.ControllerManagerServer)
local Client = require(script.ControllerManagerClient)

export type Server = Server.ServerControllerManager
export type Client = Client.ControllerManager

return {
	Server = Server,
	Client = Client,
}
