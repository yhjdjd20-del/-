import SwiftUI
import SwiftData
import CoreHaptics

@main
struct CreatureGameApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [Creature.self, PlayerProfile.self])
        }
    }
}

@Model
final class PlayerProfile {
    var souls: Int
    
    init(souls: Int = 0) {
        self.souls = souls
    }
}

@Model
final class Creature {
    var id: UUID
    var name: String
    var type: String
    var rarity: String
    var trait: String
    var strength: Int
    var speed: Int
    var intelligence: Int
    var creationDate: Date
    var isDead: Bool
    var isFavorite: Bool
    var level: Int
    var xp: Int
    var lore: String
    var avatarSeed: Int
    var expeditionEndDate: Date?
    var equippedItem: String
    
    var totalStats: Int {
        strength + speed + intelligence
    }
    
    init(id: UUID = UUID(), name: String, type: String, rarity: String, trait: String, strength: Int, speed: Int, intelligence: Int, creationDate: Date = Date(), isDead: Bool = false, isFavorite: Bool = false, level: Int = 1, xp: Int = 0, lore: String, avatarSeed: Int, expeditionEndDate: Date? = nil, equippedItem: String = "Нет") {
        self.id = id
        self.name = name
        self.type = type
        self.rarity = rarity
        self.trait = trait
        self.strength = strength
        self.speed = speed
        self.intelligence = intelligence
        self.creationDate = creationDate
        self.isDead = isDead
        self.isFavorite = isFavorite
        self.level = level
        self.xp = xp
        self.lore = lore
        self.avatarSeed = avatarSeed
        self.expeditionEndDate = expeditionEndDate
        self.equippedItem = equippedItem
    }
}

struct CreatureDTO: Codable {
    let n: String
    let t: String
    let r: String
    let tr: String
    let st: Int
    let sp: Int
    let i: Int
    let l: Int
    let lr: String
}

class GameEngine: ObservableObject {
    static let shared = GameEngine()
    
    let firstParts = ["Гром", "Зар", "Игнис", "Аква", "Терра", "Аэро", "Люкс", "Умбра", "Некро", "Драко", "Феникс", "Силван", "Калли", "Морф", "Крио", "Вольт", "Вир", "Хроно", "Пиро", "Магма", "Ксено", "Астра", "Веном", "Блайнд", "Дарк", "Лайт", "Скай", "Блад", "Вайпер", "Голем", "Гриф", "Спектр", "Фантом", "Эхо", "Орион", "Абисс", "Брон", "Ворт", "Грим", "Дум", "Зефир", "Инфер", "Краг", "Лунар", "Миф", "Нова", "Оникс", "Плазм", "Рун", "Солар"]
    let secondParts = ["мак", "ли", "тор", "зил", "гант", "рон", "мил", "тис", "вар", "дал", "фис", "лок", "зен", "рут", "мат", "вил", "сар", "ник", "рик", "лум", "бор", "зок", "тар", "мир", "фас", "лит", "вор", "дур", "гор", "шил", "кап", "зир", "нак", "рин", "фен", "зал", "мур", "дир", "бас", "гар", "вис", "сом", "тур", "лак", "нир", "пир", "сир", "тир", "хир", "кир"]
    let thirdParts = ["ос", "икс", "ор", "ус", "акс", "ия", "аль", "ант", "ес", "ис", "он", "ар", "ет", "ур", "иум", "ион", "атар", "ил", "окс", "иус", "эра", "алис", "ерон", "ирон", "одор", "агон", "игор", "отар", "ирис", "азар", "унд", "инг", "энд", "альф", "орт", "уст", "аст", "эст", "ист", "оль", "уль", "эль", "иль", "ан", "ин", "ун", "ен", "онт", "унт", "энт"]
    
    let creatureTypes = ["Огненный", "Водный", "Земляной", "Воздушный", "Световой", "Теневой", "Некротический", "Драконий", "Духовный", "Мистический", "Ледяной", "Электрический", "Ядовитый", "Призрачный"]
    let rarityLevels = ["Обычный", "Необычный", "Редкий", "Мифический", "Легендарный", "Древний"]
    let specialTraits = ["Гигант", "Сияющий", "Альфа", "Охотник", "Мутант", "Бронированный", "Космический", "Хранитель", "Титан", "Берсерк"]
    let equipment = ["Кольцо Силы", "Амулет Скорости", "Око Мудрости", "Шипованный Панцирь", "Крылья Бури", "Нет"]
    
    func typeAdvantage(attacker: String, defender: String) -> Double {
        let advantages = [
            "Огненный": ["Ледяной", "Земляной"],
            "Водный": ["Огненный", "Земляной"],
            "Земляной": ["Электрический", "Ядовитый"],
            "Воздушный": ["Земляной", "Огненный"],
            "Световой": ["Теневой", "Некротический"],
            "Теневой": ["Световой", "Мистический"]
        ]
        if let targets = advantages[attacker], targets.contains(defender) {
            return 1.5
        }
        return 1.0
    }
    
    func generateLore(type: String, trait: String) -> String {
        let places = ["в забытых руинах", "на вершинах ледяных гор", "в Бездне", "в кристальных пещерах", "в густом эфирном лесу"]
        let actions = ["пожирает души заблудших", "охраняет древние секреты", "ищет достойного противника", "медитирует в пустоте"]
        return "Это \(trait.lowercased()) существо обитает \(places.randomElement()!). Оно \(actions.randomElement()!)."
    }
    
    func generateCreature(bonus: Int = 0) -> Creature {
        let name = "\(firstParts.randomElement()!)\(secondParts.randomElement()!)\(thirdParts.randomElement()!)"
        
        if bonus >= 999 || name == "Некрозокорос" {
            return Creature(name: "Некрозокор", type: "Теневой", rarity: "Древний", trait: "Божество", strength: 999, speed: 999, intelligence: 999, lore: "Скрытое божество. Оно нашло тебя само.", avatarSeed: 999999)
        }
        
        let type = creatureTypes.randomElement()!
        var rarityIndex = Int.random(in: 0..<rarityLevels.count)
        if bonus > 20 && rarityIndex < rarityLevels.count - 1 { rarityIndex += 1 }
        
        let rarity = rarityLevels[rarityIndex]
        let trait = specialTraits.randomElement()!
        let multi = rarityIndex + 1
        
        return Creature(
            name: name,
            type: type,
            rarity: rarity,
            trait: trait,
            strength: Int.random(in: 10 * multi...50 * multi) + bonus,
            speed: Int.random(in: 5 * multi...30 * multi) + bonus,
            intelligence: Int.random(in: 1 * multi...20 * multi) + bonus,
            lore: generateLore(type: type, trait: trait),
            avatarSeed: Int.random(in: 1...1000000)
        )
    }
    
    func breed(c1: Creature, c2: Creature) -> Creature {
        let child = generateCreature(bonus: (c1.level + c2.level) * 2)
        let prefix = String(c1.name.prefix(4))
        let suffix = String(c2.name.suffix(4))
        child.name = prefix + suffix
        child.rarity = c1.rarity
        child.trait = "Мутант"
        return child
    }
}

class HapticManager {
    static let shared = HapticManager()
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [PlayerProfile]
    @Query(sort: \Creature.totalStats, order: .reverse) private var creatures: [Creature]
    
    var dynamicColor: Color {
        guard let best = creatures.filter({ !$0.isDead }).first else { return .blue }
        switch best.type {
        case "Огненный", "Драконий": return .red
        case "Водный", "Ледяной": return .cyan
        case "Земляной": return .brown
        case "Теневой", "Некротический": return .purple
        case "Световой", "Святой": return .yellow
        case "Ядовитый": return .green
        default: return .blue
        }
    }
    
    var body: some View {
        TabView {
            SummonView()
                .tabItem { Label("Призыв", systemImage: "sparkles") }
            BestiaryView()
                .tabItem { Label("Бестиарий", systemImage: "list.dash") }
            ArenaView()
                .tabItem { Label("Арена", systemImage: "shield.lefthalf.filled") }
            GraveyardView()
                .tabItem { Label("Морг", systemImage: "cross.case.fill") }
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
        }
        .tint(dynamicColor)
        .onAppear {
            if profiles.isEmpty {
                context.insert(PlayerProfile())
            }
        }
    }
}

struct SummonView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [PlayerProfile]
    
    @State private var timeRemaining = 3.0
    @State private var isTapping = false
    @State private var tapCount = 0
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var lastSummoned: Creature?
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Души: \(profiles.first?.souls ?? 0)")
                .font(.headline)
            
            if isTapping {
                Text(String(format: "%.1f", timeRemaining))
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.red)
                Text("Тапы: \(tapCount)")
                    .font(.title)
                
                Button(action: {
                    tapCount += 1
                    HapticManager.shared.impact(style: .light)
                }) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 200, height: 200)
                        .overlay(Text("ТАП!").font(.largeTitle).bold().foregroundColor(.white))
                }
            } else {
                Button(action: startMiniGame) {
                    Text("Начать ритуал")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                if profiles.first?.souls ?? 0 >= 100 {
                    Button(action: boostSummon) {
                        Text("Усиленный ритуал (100 душ)")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .sheet(isPresented: $showResult) {
            if let creature = lastSummoned {
                CreatureDetailView(creature: creature)
            }
        }
    }
    
    func startMiniGame() {
        tapCount = 0
        timeRemaining = 3.0
        isTapping = true
        HapticManager.shared.impact(style: .medium)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                t.invalidate()
                finishSummon(bonus: tapCount)
            }
        }
    }
    
    func boostSummon() {
        if let p = profiles.first, p.souls >= 100 {
            p.souls -= 100
            finishSummon(bonus: 50)
        }
    }
    
    func finishSummon(bonus: Int) {
        isTapping = false
        let creature = GameEngine.shared.generateCreature(bonus: bonus)
        context.insert(creature)
        lastSummoned = creature
        showResult = true
        HapticManager.shared.impact(style: .heavy)
    }
}

struct BestiaryView: View {
    @Query(filter: #Predicate<Creature> { !$0.isDead }, sort: \Creature.creationDate, order: .reverse) private var creatures: [Creature]
    @Environment(\.modelContext) private var context
    @State private var filterType = "Все"
    @State private var showBreed = false
    @State private var breedParent1: Creature?
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Фильтр", selection: $filterType) {
                    Text("Все").tag("Все")
                    Text("Избранные").tag("Избранные")
                    ForEach(GameEngine.shared.creatureTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                List {
                    ForEach(filteredCreatures) { creature in
                        NavigationLink(destination: CreatureDetailView(creature: creature)) {
                            HStack {
                                AvatarView(seed: creature.avatarSeed, type: creature.type)
                                    .frame(width: 50, height: 50)
                                VStack(alignment: .leading) {
                                    Text(creature.name)
                                        .font(.headline)
                                        .foregroundColor(creature.isFavorite ? .orange : .primary)
                                    Text("\(creature.type) • Lvl \(creature.level)")
                                        .font(.caption)
                                }
                                Spacer()
                                if let end = creature.expeditionEndDate, end > Date() {
                                    Image(systemName: "timer")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button(action: { creature.isFavorite.toggle() }) {
                                Image(systemName: "star.fill")
                            }.tint(.yellow)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive, action: { kill(creature) }) {
                                Label("Убить", systemImage: "skull")
                            }
                            if breedParent1 == nil {
                                Button(action: { breedParent1 = creature }) {
                                    Label("Скрестить", systemImage: "heart.fill")
                                }.tint(.pink)
                            } else if breedParent1?.id != creature.id {
                                Button(action: { executeBreed(c2: creature) }) {
                                    Label("Выбрать", systemImage: "checkmark")
                                }.tint(.green)
                            }
                        }
                    }
                }
                if breedParent1 != nil {
                    Button("Отменить скрещивание") { breedParent1 = nil }
                        .padding()
                }
            }
            .navigationTitle("Бестиарий (\(filteredCreatures.count))")
        }
    }
    
    var filteredCreatures: [Creature] {
        if filterType == "Все" { return creatures }
        if filterType == "Избранные" { return creatures.filter { $0.isFavorite } }
        return creatures.filter { $0.type == filterType }
    }
    
    func kill(_ creature: Creature) {
        if !creature.isFavorite {
            creature.isDead = true
            HapticManager.shared.impact(style: .rigid)
        }
    }
    
    func executeBreed(c2: Creature) {
        if let c1 = breedParent1 {
            let child = GameEngine.shared.breed(c1: c1, c2: c2)
            context.insert(child)
            breedParent1 = nil
            HapticManager.shared.impact(style: .heavy)
        }
    }
}

struct CreatureDetailView: View {
    @Bindable var creature: Creature
    @State private var exportCode = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AvatarView(seed: creature.avatarSeed, type: creature.type)
                    .frame(width: 150, height: 150)
                
                Text(creature.name)
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    Text(creature.type).padding(8).background(Color.blue.opacity(0.2)).cornerRadius(8)
                    Text(creature.rarity).padding(8).background(Color.purple.opacity(0.2)).cornerRadius(8)
                    Text("Ур. \(creature.level)").padding(8).background(Color.green.opacity(0.2)).cornerRadius(8)
                }
                
                Text(creature.lore)
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    StatBar(label: "Сила", value: creature.strength, max: 500, color: .red)
                    StatBar(label: "Скорость", value: creature.speed, max: 300, color: .yellow)
                    StatBar(label: "Интеллект", value: creature.intelligence, max: 200, color: .blue)
                    StatBar(label: "Опыт (XP)", value: creature.xp, max: creature.level * 100, color: .green)
                }.padding()
                
                Button(action: generateExportCode) {
                    Text("Экспорт существа")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                }.padding(.horizontal)
                
                if !exportCode.isEmpty {
                    Text(exportCode)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if creature.expeditionEndDate == nil {
                    Button(action: {
                        creature.expeditionEndDate = Date().addingTimeInterval(14400)
                    }) {
                        Text("Отправить в экспедицию (4ч)")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.padding(.horizontal)
                } else if let end = creature.expeditionEndDate, end < Date() {
                    Button(action: {
                        creature.expeditionEndDate = nil
                        creature.xp += 150
                        checkLevelUp()
                    }) {
                        Text("Завершить экспедицию")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.padding(.horizontal)
                } else {
                    Text("В экспедиции...")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    func generateExportCode() {
        let dto = CreatureDTO(n: creature.name, t: creature.type, r: creature.rarity, tr: creature.trait, st: creature.strength, sp: creature.speed, i: creature.intelligence, l: creature.level, lr: creature.lore)
        if let data = try? JSONEncoder().encode(dto) {
            exportCode = data.base64EncodedString()
        }
    }
    
    func checkLevelUp() {
        let threshold = creature.level * 100
        if creature.xp >= threshold {
            creature.level += 1
            creature.strength += 10
            creature.speed += 5
            creature.intelligence += 5
            creature.xp -= threshold
            HapticManager.shared.impact(style: .heavy)
        }
    }
}

struct StatBar: View {
    let label: String
    let value: Int
    let max: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule().fill(color).frame(width: min(CGFloat(value) / CGFloat(max) * geo.size.width, geo.size.width))
                }
            }.frame(height: 12)
            Text("\(value)").bold()
        }
    }
}

struct AvatarView: View {
    let seed: Int
    let type: String
    
    var color: Color {
        switch type {
        case "Огненный": return .red
        case "Водный": return .blue
        case "Земляной": return .brown
        case "Теневой": return .black
        case "Световой": return .yellow
        default: return .purple
        }
    }
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            context.fill(Path(ellipseIn: CGRect(x: 0, y: 0, width: w, height: h)), with: .color(color.opacity(0.3)))
            
            let drawSeed = abs(seed)
            if drawSeed % 2 == 0 {
                context.fill(Path(CGRect(x: w*0.2, y: h*0.2, width: w*0.6, height: h*0.6)), with: .color(color))
            } else {
                var triangle = Path()
                triangle.move(to: CGPoint(x: w/2, y: h*0.1))
                triangle.addLine(to: CGPoint(x: w*0.9, y: h*0.9))
                triangle.addLine(to: CGPoint(x: w*0.1, y: h*0.9))
                context.fill(triangle, with: .color(color))
            }
        }
    }
}

struct ArenaView: View {
    @Query(filter: #Predicate<Creature> { !$0.isDead }) private var creatures: [Creature]
    @Environment(\.modelContext) private var context
    @State private var log = "Добро пожаловать на Арену!"
    @State private var enemyHealth = 1000
    @State private var wave = 1
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Волна: \(wave)").font(.largeTitle).bold()
            Text("Здоровье Босса: \(enemyHealth)")
                .font(.title2)
                .foregroundColor(.red)
            
            ScrollView {
                Text(log)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            Button("Автобой (Отряд до 3)") {
                fight()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    func fight() {
        let team = creatures.sorted { $0.totalStats > $1.totalStats }.prefix(3)
        guard !team.isEmpty else {
            log = "Нет живых существ для боя!"
            return
        }
        
        var currentLog = "Начат бой с Боссом!\n"
        var damageDealt = 0
        
        for c in team {
            let dmg = c.strength * (1 + (c.intelligence / 100))
            damageDealt += dmg
            currentLog += "\(c.name) наносит \(dmg) урона.\n"
        }
        
        enemyHealth -= damageDealt
        
        if enemyHealth <= 0 {
            currentLog += "Босс повержен! Отряд получает опыт."
            wave += 1
            enemyHealth = wave * 1500
            for c in team { c.xp += 50 }
            HapticManager.shared.impact(style: .heavy)
        } else {
            currentLog += "Босс контратакует! Самое слабое существо гибнет."
            if let weakest = team.last {
                weakest.isDead = true
                currentLog += "\n\(weakest.name) пал в бою."
            }
        }
        log = currentLog
    }
}

struct GraveyardView: View {
    @Query(filter: #Predicate<Creature> { $0.isDead }) private var deadCreatures: [Creature]
    @Query private var profiles: [PlayerProfile]
    
    var body: some View {
        NavigationView {
            List(deadCreatures) { creature in
                VStack(alignment: .leading) {
                    Text(creature.name).font(.headline).strikethrough()
                    Text("Ур. \(creature.level) • Пал в бою").font(.caption)
                }
                .swipeActions {
                    Button("Воскресить (50 Душ)") {
                        if let p = profiles.first, p.souls >= 50 {
                            p.souls -= 50
                            creature.isDead = false
                        }
                    }.tint(.green)
                    Button("Распылить") {
                        if let p = profiles.first {
                            p.souls += creature.level * 10
                            creature.modelContext?.delete(creature)
                        }
                    }.tint(.orange)
                }
            }
            .navigationTitle("Морг")
        }
    }
}

struct ProfileView: View {
    @Query(filter: #Predicate<Creature> { !$0.isDead }, sort: \Creature.totalStats, order: .reverse) private var creatures: [Creature]
    @Query private var profiles: [PlayerProfile]
    @State private var importString = ""
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Баланс Душ: \(profiles.first?.souls ?? 0)")
                    .font(.title)
                    .padding()
                
                Text("Зал Славы (Топ 3)").font(.headline)
                ForEach(creatures.prefix(3)) { c in
                    HStack {
                        Text(c.name).bold()
                        Spacer()
                        Text("Статы: \(c.totalStats)")
                    }.padding(.horizontal)
                }
                
                Divider().padding()
                
                TextField("Вставь код существа", text: $importString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Импортировать") {
                    if let data = Data(base64Encoded: importString),
                       let dto = try? JSONDecoder().decode(CreatureDTO.self, from: data) {
                        let newCreature = Creature(name: dto.n, type: dto.t, rarity: dto.r, trait: dto.tr, strength: dto.st, speed: dto.sp, intelligence: dto.i, level: dto.l, lore: dto.lr, avatarSeed: Int.random(in: 1...100000))
                        context.insert(newCreature)
                        importString = ""
                        HapticManager.shared.impact(style: .medium)
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Профиль")
        }
    }
}
