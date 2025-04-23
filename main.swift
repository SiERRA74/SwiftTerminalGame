import Foundation

func clear(){
    print("\u{001B}[2J")
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


var rooms = loadRooms()
var currentRoomID = 1

func main() {
    let isRunning = true

    while isRunning, let currentRoom = rooms[currentRoomID] {

        print("\nWhat do you want to do?")
        print("1. Read intro")
        print("2. List items")
        print("3. Solve puzzle")
        print("4. Move")
        print("5. Quit")

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

                case "4":
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

                case "5":
                    print("Thanks for playing!")
                    break
                default:
                    print("Invalid choice")
            }
        }
    }
}

start()
