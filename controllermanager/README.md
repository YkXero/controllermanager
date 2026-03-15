# ControllerManager

A robust, two-phase loading system for modular character controllers in Roblox. This system enables clean dependency management, automatic cleanup, and parallel loading for both Client and Server environments.

## Features

- **Two-Phase Loading**: Ensures all modules are constructed before any initialization logic runs.
- **Parallel Construction**: Loads modules asynchronously using Promises for maximum performance.
- **Automatic Cleanup**: Integrated with [Janitor](https://github.com/steven-isbell/janitor) for seamless memory management.
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

### Client Setup
```lua
local ControllerManager = require(path.to.ControllerManager).Client
local manager = ControllerManager.new({ script.Parent.Controllers })

-- Load controllers for a character
manager:Load(player.Character):andThen(function(controllers)
    print("Character controllers ready!")
end)
```

### Server Setup
```lua
local ControllerManager = require(path.to.ControllerManager).Server
local manager = ControllerManager.new({ game.ServerScriptService.Services })

-- Initialize and start all services
manager:Load():andThen(function()
    print("Server services initialized and started!")
end)
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
