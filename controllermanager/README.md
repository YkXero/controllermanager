# ControllerManager

A robust, two-phase loading system for modular character controllers in Roblox. This system enables clean dependency management, automatic cleanup, and parallel loading for both Client and Server environments.

## Features

- **Two-Phase Loading**: Ensures all modules are constructed before any initialization logic runs.
- **Parallel Construction**: Loads modules asynchronously for maximum performance.
- **Automatic Cleanup**: Integrated with Janitor for seamless memory management.
- **Retry Logic**: Built-in retry mechanisms for modules that depend on streaming or slow-loading instances.
- **Shared Architecture**: Consistent API between `ControllerManagerClient` and `ControllerManagerServer`.

## Architecture

### 1. Construction Phase (`.new`)
- Modules are required.
- Constructors (`.new` or `.New`) are called.
- Controllers are stored but should **not** reference other controllers yet.

### 2. Initialization Phase (`:Initialize`)
- Called automatically after **all** controllers in the set are constructed.
- Safe to use `Manager:GetController()` to cross-reference other modules.

### 3. Start Phase (`:Start` / `:Load`)
- *Server-only*: A third phase for starting time-dependent logic or network listeners.

## Quick Start

### Client Setup (Loader)

Load character controllers and configure humanoid states when a player spawns.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ControllerManager = require(Packages:WaitForChild("ControllerManager")).Client

local Player = game.Players.LocalPlayer
local ClientFolder = ReplicatedStorage:WaitForChild("Client")

-- Initialize Manager with specific controller folders
local Manager = ControllerManager.new({
    ClientFolder.Player.Movement, -- Examples
    ClientFolder.UI, -- Examples
}, {
    MaxRetries = 5,
    RetryInterval = 10,
    KickOnFailure = true,
})

-- Load controllers when character joins
Player.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid")

    Manager:Load(Character)
end)
```

### Server Setup

Initialize and start server-side services from a central loader.

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ControllerManager = require(Packages.ControllerManager).Server
local Services = ServerScriptService:WaitForChild("Server").Services

local ServerControllers = ControllerManager.new({
    Services.Player.Loader,
    -- Add other services here
})

ServerControllers:Load()
```

## Creating a Controller

Each module script should return a table with a `.new` constructor.

```lua
local MyController = {}

function MyController.new(character, manager)
    local self = setmetatable({}, MyController)
    return self
end

function MyController:Initialize()
    -- Safe to talk to other controllers here
    self.OtherController = self.Manager:GetController(self.Character, "OtherController")
end

function MyController:Destroy()
    -- Cleanup logic
end

return MyController
```
