import Foundation
import Glibc



func clear(){
    print("\u{001B}[2J")
}

func help_message() {
    clear()
    print("""
    You're playing text-based exploration game where you solve puzzles,
    combine items, and uncover secrets to progress deeper.

    ===  CONTROLS ===
    [1] Read intro      - Read the room's description.
    [2] List items      - See all interactable objects in the room.
    [3] Inspect objects - Read the description of the adventurer of each objects
    [4] Solve puzzle    - Combine items or input codes to progress.
    [5] Move            - Travel to the next room (if solved).
    [6] Quit            - Exit the game.
    [?] Help            - To see this message.

    === PUZZLE MECHANICS ===
    - Some rooms require crafting (e.g., combine stick + cloth = torch).
    - Others need codes (e.g., inspect items to find hidden digits).
    - Example input for combining: "1 3" (item numbers separated by spaces).

    === TIPS ===
    - Pay attention to item descriptions—they often hide clues!
    - Wrong combinations? Just try again or type 'x' to cancel.
    - Not all items are useful—some are red herrings. 🐟

    Press [ENTER] to return to the game...
    """)
    _ = readLine()  // Wait for user to press Enter
    clear()
}


func loadRooms() -> [Int: Room] {
    let url = URL(fileURLWithPath: "rooms.json") // file in the same dir
    do {
        let data = try Data(contentsOf: url)
        let roomList = try JSONDecoder().decode([Room].self, from: data)
        let roomDict = Dictionary(uniqueKeysWithValues: roomList.map { ($0.id, $0) })
        return roomDict
    } catch {
        print("Failed to load rooms: \(error)")
        return [:]
    }
}

//Structure of the rooms
struct Room: Codable {
    let id: Int
    let name: String
    var next_room: [Int]
    var intro: String
    var items: [String]
    var itemsdesc:[String: String]
    var solution: [Int]
    var solved: Bool
    var success: String

    func entered() {
        clear()
        print("You entered room n°0\(id): \"\(name)\"")
        print(intro)

    }

    func listItems() {
        clear()
        for (i, item) in items.enumerated() {
            print("\(i + 1). \(item)")
        }
    }

    func solve(){
        listItems()
        print("Write down the indexes of the items you want to combine or craft to solve the room \n example : '2 4' (press ENTER afterwards)")
        print("\nx. to go back")

    }


    // Add CodingKeys to handle JSON key mismatches
    enum CodingKeys: String, CodingKey {
        case id, name, next_room, intro, items
        case itemsdesc = "items-desc"  // Maps JSON's "items-desc" to `itemsdesc`
        case solution, solved, success
    }
}


func solution_check(guess: String) -> [Int] {
    return guess.components(separatedBy: " ").compactMap { Int($0) }
}

func start() {
    print("Hello, welcome to the adventure,\nPress 'ENTER' to START")
    _ = readLine()  // Wait for any input
    clear()
    main()
}


func inspect() {
    guard let currentRoom = rooms[currentRoomID] else {
        print("Error: Current room not found")
        return
    }

    let items = currentRoom.itemsdesc  // Correct dictionary declaration
    let itemKeys = Array(items.keys)   // Get array of item names
    var index = 0

    while true {
        clear()
        print("Item Inspection (use ← → arrows to navigate, ENTER to exit)")
        print("========================================")
        print("Current item: \(itemKeys[index])")
        print("\nDescription:")
        print(items[itemKeys[index]] ?? "No description available")

        if let key = readKeyPress() {
            switch key {
                case "left":
                    index = (index - 1 + itemKeys.count) % itemKeys.count
                case "right":
                    index = (index + 1) % itemKeys.count
                case "enter":
                    return
                default:
                    break
            }
        }
    }
}

var rooms = loadRooms()
var currentRoomID = 1

func main() {
    let isRunning = true

    while isRunning, let currentRoom = rooms[currentRoomID] {

        print("\nWhat do you want to do?")
        print("1. Read intro")
        print("2. List items")
        print("3. Inspect objects")
        print("4. Solve puzzle")
        print("5. Move")
        print("6. Quit")
        print("?. Help")

        if let choice = readLine() {
            switch choice {
                case "1":
                    if currentRoom.solved == true{
                        print("You solved this level, you can use 'Move' to \ngo to the next room")
                    }else{
                        currentRoom.entered()
                    }

                case "2":
                    currentRoom.listItems()

                case "3":
                    inspect()

                case "4":
                    currentRoom.solve()
                    while true {
                        guard let input = readLine() else { continue }

                        if input.lowercased() == "x" {
                            break  // Exit solve menu
                        }

                        let guess = solution_check(guess: input)
                        if guess == currentRoom.solution {
                            print(currentRoom.success)
                            rooms[currentRoomID]?.solved = true
                            break  // Exit after solving
                        } else {
                            print("Wrong combination. Try again or type 'x' to go back.")
                        }
                    }

                case "5":
                    if currentRoom.solved == true{
                        print("Next rooms : \(currentRoom.next_room)")
                        print("Enter room number to go:")
                        if let input = readLine(), let nextRoomID = Int(input),
                            currentRoom.next_room.contains(nextRoomID) {
                                currentRoomID = nextRoomID
                            } else {
                                print("Can't go there.")
                            }
                    }else{
                        print("You need to solve the room first")
                    }

                case "6":
                    print("Thanks for playing!")
                    break

                case "?":
                    help_message()
                    break

                default:
                    print("Invalid choice")
            }
        }
    }
}

start()
