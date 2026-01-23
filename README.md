# PhantomGamble

A comprehensive gambling addon for Turtle WoW (1.12 compatible) that helps organize and track roll-based gold games.

## Features

### Two Gambling Modes

**Regular Gamble (Left Side)**
- Host roll-off games with multiple players
- Players type `1` in chat to join, `-1` to withdraw
- All players roll, highest wins, lowest pays the difference
- Supports 2+ players per game

**Death Roll (Right Side)**
- Classic 1v1 death roll format
- Customizable starting number (10, 50, 100, 1,000, or 10,000)
- Separate gold wager amount (bet 50g on a 1000 start, for example)
- Players take turns rolling, each roll becomes the new maximum
- First to roll a 1 loses and pays the wager

### Statistics Tracking

- **All-Time Stats**: Tracks total gold won/lost per player
- **Leaderboard**: Color-coded display (green = winners, red = losers)
- **Chat Reporting**: Announce Top 5/10/15 winners or Bottom 5/Last place to chat

### Debt Tracking System

- Automatically tracks who owes whom after each game
- Debts accumulate and can cancel out between players
- Players confirm payments by typing `!paid PlayerName Amount` in chat
- Outstanding debts window shows all unpaid balances

## Installation

1. Download the addon files
2. Extract to your `World of Warcraft/Interface/AddOns/` folder
3. Ensure the folder is named `PhantomGamble` and contains:
   - `PhantomGamble.lua`
   - `PhantomGamble.toc`
4. Restart WoW or type `/reload`

## Usage

### Opening the Addon
- Click the minimap button (gold coin icon)
- Type `/pg show`

### Main Window Buttons

| Button | Description |
|--------|-------------|
| **S** (Gold) | Opens Statistics window |
| **D** (Orange) | Opens Debts window |

### Regular Gamble (Left Side)

1. Enter the gold amount in the text box
2. Click **Open Entry** to start accepting players
3. Players type `1` in chat to join
4. Click **Last Call** to warn players
5. Click **Roll** to close entry and prompt rolls
6. Click **Cancel** to abort the game

### Death Roll (Right Side)

1. Click the **Start** dropdown to select starting number
2. Enter the gold wager in the **Gold** field
3. Click **Start Death Roll**
4. Two players type `1` to join
5. Players take turns rolling until someone hits 1
6. Loser pays the wager amount

### Bottom Controls

| Button | Description |
|--------|-------------|
| **RAID/PARTY/GUILD/SAY** | Click to cycle chat channel |
| **(Whispers)/(No Whispers)** | Toggle private join confirmations |

## Slash Commands

| Command | Description |
|---------|-------------|
| `/pg` | Show available commands |
| `/pg show` | Show the main window |
| `/pg hide` | Hide the main window |
| `/pg stats` | Open statistics window |
| `/pg debts` | Open debts window |
| `/pg reset` | Reset current game state |
| `/pg fullstats` | Print all stats to chat |
| `/pg resetstats` | Clear all statistics |
| `/pg resetdebts` | Clear all debt records |
| `/pg minimap` | Toggle minimap button |
| `/pg ban Name` | Ban a player from joining |
| `/pg unban Name` | Remove a player's ban |
| `/pg listban` | Show all banned players |

## Confirming Payments

When a player pays their debt, they can type in chat:

```
!paid PlayerName Amount
```

**Example:** `!paid Bob 50` confirms you paid Bob 50 gold.

The addon will:
- Announce the payment to chat
- Update the debt ledger
- Reduce or clear the outstanding debt

## Statistics Window

Access via the **S** button or `/pg stats`

- **Scrollable leaderboard** of all players
- **Color coding**: Green (profit), Red (loss), Yellow (even)
- **Report buttons**: Announce rankings to chat
  - Top 5 / Top 10 / Top 15 - Winners
  - Bot 5 - Bottom 5 losers
  - Last - Biggest loser
- **Reset Stats** - Clear all historical data

## Debts Window

Access via the **D** button or `/pg debts`

- Shows all outstanding debts
- Format: "PlayerA owes PlayerB X gold"
- **Report Debts** - Announce debts to chat
- **Clear All Debts** - Wipe debt records

## Data Persistence

All data is saved automatically when you:
- Log out
- Reload UI (`/reload`)
- Exit the game

Saved data includes:
- Statistics (wins/losses per player)
- Outstanding debts
- Window positions
- Last used settings (chat channel, roll amounts, etc.)
- Ban list

## Tips

- The addon only listens to the selected chat channel (RAID/PARTY/GUILD/SAY)
- Use **Last Call** to give players a final warning before rolling
- Death Roll wager can be different from the starting number for varied risk/reward
- Debts automatically consolidate (if A owes B, then B owes A, they offset)
- Ban problematic players with `/pg ban Name`

## Changelog

### Version 1.0
- Initial release
- Regular gambling mode with multi-player support
- Death Roll mode with customizable start/wager
- Statistics tracking with leaderboard
- Debt tracking system with payment confirmation
- Chat channel selection
- Whisper notifications toggle
- Player ban system
- Minimap button
- Resizable windows
