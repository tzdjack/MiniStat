// MiniStat - macOS 菜单栏系统监视器
// 构建：swiftc -O -o MiniStat MiniStat.swift -framework Cocoa -framework IOKit -framework Metal

import Cocoa
import IOKit
import IOKit.ps
import Metal

// MARK: - 常量

enum Constants {
    static let bytesPerGB: UInt64 = 1024 * 1024 * 1024
    static let bytesPerMB: UInt64 = 1024 * 1024
    static let bytesPerKB: UInt64 = 1024
}

// MARK: - 本地化

enum Language: String, CaseIterable {
    case chinese = "zh"
    case english = "en"
    case turkish = "tr"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case japanese = "ja"
    
    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .japanese: return "日本語"
        }
    }
}

struct L10n {
    static var current: Language {
        get {
            if let code = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = Language(rawValue: code) {
                return lang
            }
            // 从系统自动检测（兼容 macOS 12+）
            let systemLang: String
            if #available(macOS 13, *) {
                systemLang = Locale.current.language.languageCode?.identifier ?? "zh"
            } else {
                systemLang = Locale.current.languageCode ?? "zh"
            }
            return Language(rawValue: systemLang) ?? .chinese
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage") }
    }

    // 全部可翻译字符串
    static var cpu: String { tr("CPU", "CPU", "CPU", "CPU", "CPU", "CPU", "CPU") }
    static var memory: String { tr("Memory", "Bellek", "Speicher", "Mémoire", "Memoria", "メモリ", "内存") }
    static var gpu: String { tr("GPU", "GPU", "GPU", "GPU", "GPU", "GPU", "GPU") }
    static var network: String { tr("Network", "Ağ", "Netzwerk", "Réseau", "Red", "ネットワーク", "网络") }
    static var disk: String { tr("Disk", "Disk", "Festplatte", "Disque", "Disco", "ディスク", "磁盘") }
    static var battery: String { tr("Battery", "Pil", "Akku", "Batterie", "Batería", "バッテリー", "电池") }
    static var charging: String { tr("Charging", "Şarj oluyor", "Lädt", "En charge", "Cargando", "充電中", "充电中") }
    static var fans: String { tr("Fans", "Fanlar", "Lüfter", "Ventilateurs", "Ventiladores", "ファン", "风扇") }
    static var system: String { tr("System", "Sistem", "System", "Système", "Sistema", "システム", "系统") }
    static var temperature: String { tr("Temperature", "Sıcaklık", "Temperatur", "Température", "Temperatura", "温度", "温度") }
    static var cores: String { tr("cores", "çekirdek", "Kerne", "cœurs", "núcleos", "コア", "核心") }
    static var processes: String { tr("Processes", "İşlemler", "Prozesse", "Processus", "Procesos", "プロセス", "进程") }
    static var uptime: String { tr("Uptime", "Çalışma süresi", "Laufzeit", "Temps de fonctionnement", "Tiempo activo", "稼働時間", "运行时间") }
    static var localIP: String { tr("Local", "Yerel", "Lokal", "Local", "Local", "ローカル", "本地") }
    static var publicIP: String { tr("Public", "Genel", "Öffentlich", "Publique", "Pública", "パブリック", "公网") }
    static var session: String { tr("Session", "Oturum", "Sitzung", "Session", "Sesión", "セッション", "会话") }
    static var freeOf: String { tr("free of", "boş /", "frei von", "libre sur", "libre de", "空き/", "可用/") }
    static var remaining: String { tr("remaining", "kaldı", "verbleibend", "restant", "restante", "残り", "剩余") }
    static var connectedToPower: String { tr("Connected to power", "Güce bağlı", "Mit Strom verbunden", "Connecté au secteur", "Conectado a la corriente", "電源に接続", "已连接电源") }
    static var notInUse: String { tr("Not in use", "Kullanılmıyor", "Nicht verwendet", "Non utilisé", "No en uso", "未使用", "未使用") }
    static var language: String { tr("Language", "Dil", "Sprache", "Langue", "Idioma", "言語", "语言") }
    static var about: String { tr("About MiniStat", "MiniStat Hakkında", "Über MiniStat", "À propos de MiniStat", "Acerca de MiniStat", "MiniStatについて", "关于MiniStat") }
    static var quit: String { tr("Quit", "Çıkış", "Beenden", "Quitter", "Salir", "終了", "退出") }
    static var theme: String { tr("Theme", "Tema", "Thema", "Thème", "Tema", "テーマ", "主题") }
    static var power: String { tr("Power", "Güç", "Strom", "Alimentation", "Energía", "電源", "电源") }
    static var connectedToAdapter: String { tr("Connected to power adapter", "Güç adaptörüne bağlı", "Mit Netzteil verbunden", "Connecté à l'adaptateur", "Conectado al adaptador", "電源アダプタに接続", "已连接电源适配器") }
    static var fan: String { tr("Fan", "Fan", "Lüfter", "Ventilateur", "Ventilador", "ファン", "风扇") }
    static var load: String { tr("Load", "Yük", "Last", "Charge", "Carga", "負荷", "负载") }
    static var swap: String { tr("Swap", "Takas", "Swap", "Swap", "Intercambio", "スワップ", "交换") }
    static var kernel: String { tr("Kernel", "Çekirdek", "Kernel", "Noyau", "Kernel", "カーネル", "内核") }
    static var ssdHealth: String { tr("SSD Health", "SSD Sağlığı", "SSD-Zustand", "Santé SSD", "Salud SSD", "SSD健康", "SSD健康") }
    static var brightness: String { tr("Brightness", "Parlaklık", "Helligkeit", "Luminosité", "Brillo", "明るさ", "亮度") }
    static var powerUsage: String { tr("Power", "Güç", "Leistung", "Puissance", "Potencia", "消費電力", "功耗") }
    static var frequency: String { tr("Frequency", "Frekans", "Frequenz", "Fréquence", "Frecuencia", "周波数", "频率") }

    private static func tr(_ en: String, _ tr: String, _ de: String, _ fr: String, _ es: String, _ ja: String, _ zh: String) -> String {
        switch current {
        case .chinese: return zh
        case .english: return en
        case .turkish: return tr
        case .german: return de
        case .french: return fr
        case .spanish: return es
        case .japanese: return ja
        }
    }
}



// MARK: - 应用主题

enum AppTheme: String, CaseIterable {
    case dark = "dark"
    case light = "light"

    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

// MARK: - 设置

class Settings {
    static let shared = Settings()

    private let themeKey = "appTheme"

    var theme: AppTheme {
        get { AppTheme(rawValue: UserDefaults.standard.string(forKey: themeKey) ?? "dark") ?? .dark }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: themeKey) }
    }
}

// MARK: - 主题

struct Theme {
    static var current: AppTheme { Settings.shared.theme }

    // 背景颜色
    static var bg: NSColor {
        current == .dark
            ? NSColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0)
            : NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    }

    // 卡片渐变颜色
    static var cardGradientTop: NSColor {
        current == .dark
            ? NSColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1.0)
            : NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    static var cardGradientBottom: NSColor {
        current == .dark
            ? NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0)
            : NSColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
    }

    // 卡片边框
    static var cardBorder: NSColor {
        current == .dark
            ? NSColor(white: 0.18, alpha: 0.5)
            : NSColor(white: 0.85, alpha: 0.8)
    }

    // 进度条背景
    static var progressBg: NSColor {
        current == .dark
            ? NSColor(white: 0.15, alpha: 1)
            : NSColor(white: 0.88, alpha: 1)
    }

    static let accent = NSColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

    // 强调色（适配明暗主题）
    static let cpu = NSColor(red: 0.35, green: 0.55, blue: 1.0, alpha: 1.0)
    static let mem = NSColor(red: 1.0, green: 0.45, blue: 0.35, alpha: 1.0)
    static let gpu = NSColor(red: 0.95, green: 0.35, blue: 0.55, alpha: 1.0)
    static let net = NSColor(red: 0.25, green: 0.9, blue: 0.55, alpha: 1.0)
    static let netUp = NSColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0)
    static let disk = NSColor(red: 0.95, green: 0.65, blue: 0.15, alpha: 1.0)
    static let batt = NSColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
    static let temp = NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    static let fan = NSColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
    static let system = NSColor(red: 0.6, green: 0.5, blue: 0.9, alpha: 1.0)

    // 文字颜色（提升浅色主题可读性）
    static var text: NSColor {
        current == .dark
            ? NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
            : NSColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
    }

    static var text2: NSColor {
        current == .dark
            ? NSColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
            : NSColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)
    }

    static var text3: NSColor {
        current == .dark
            ? NSColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 1.0)
            : NSColor(red: 0.55, green: 0.55, blue: 0.60, alpha: 1.0)
    }

    static let warning = NSColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1.0)
    static let danger = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
}

// MARK: - SMC

class SMCService {
    private var connection: io_connect_t = 0
    private var isConnected = false

    struct SMCKeyData {
        var key: UInt32 = 0
        var vers = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt16(0))
        var pLimitData = (UInt16(0), UInt16(0), UInt32(0), UInt32(0), UInt32(0))
        var keyInfo = (UInt32(0), UInt32(0), UInt8(0))
        var result: UInt8 = 0
        var status: UInt8 = 0
        var data8: UInt8 = 0
        var data32: UInt32 = 0
        var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    }

    init() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return }
        let result = IOServiceOpen(service, mach_task_self_, 0, &connection)
        IOObjectRelease(service)
        isConnected = (result == kIOReturnSuccess)
    }

    deinit { if isConnected { IOServiceClose(connection) } }

    func getCPUTemperature() -> Double? {
        // 针对不同 Mac 机型尝试多个键值
        // Apple Silicon：Tp09, Tp0T, Tp01, Tp05
        // Intel：TC0P, TC0H, TC0D, TC0E, TC0F
        let keys = ["Tp09", "Tp0T", "Tp01", "Tp05", "TC0P", "TC0H", "TC0D", "TC0E", "TC0F"]
        for key in keys {
            if let temp = readTemperature(key: key), temp > 0 && temp < 120 {
                return temp
            }
        }
        return nil
    }

    func getGPUTemperature() -> Double? {
        // Apple Silicon：Tg0f, Tg0j
        // Intel：TG0P, TG0H, TG0D
        let keys = ["Tg0f", "Tg0j", "TG0P", "TG0H", "TG0D"]
        for key in keys {
            if let temp = readTemperature(key: key), temp > 0 && temp < 120 {
                return temp
            }
        }
        return nil
    }

    func getFanSpeed(fan: Int) -> Int? { return readFanRPM(key: fan == 0 ? "F0Ac" : "F1Ac") }

    private func readTemperature(key: String) -> Double? {
        guard isConnected else { return nil }
        var inputStruct = SMCKeyData()
        var outputStruct = SMCKeyData()
        inputStruct.key = stringToUInt32(key)
        inputStruct.data8 = 5
        let inputSize = MemoryLayout<SMCKeyData>.size
        var outputSize = MemoryLayout<SMCKeyData>.size
        let result = IOConnectCallStructMethod(connection, 2, &inputStruct, inputSize, &outputStruct, &outputSize)
        guard result == kIOReturnSuccess else { return nil }
        return Double(Int16(outputStruct.bytes.0) << 8 | Int16(outputStruct.bytes.1)) / 256.0
    }

    private func readFanRPM(key: String) -> Int? {
        guard isConnected else { return nil }
        var inputStruct = SMCKeyData()
        var outputStruct = SMCKeyData()
        inputStruct.key = stringToUInt32(key)
        inputStruct.data8 = 5
        let inputSize = MemoryLayout<SMCKeyData>.size
        var outputSize = MemoryLayout<SMCKeyData>.size
        let result = IOConnectCallStructMethod(connection, 2, &inputStruct, inputSize, &outputStruct, &outputSize)
        guard result == kIOReturnSuccess else { return nil }
        return Int((UInt16(outputStruct.bytes.0) << 6) + (UInt16(outputStruct.bytes.1) >> 2))
    }

    private func stringToUInt32(_ str: String) -> UInt32 {
        var result: UInt32 = 0
        for (i, char) in str.prefix(4).enumerated() { result |= UInt32(char.asciiValue ?? 0) << (24 - i * 8) }
        return result
    }

    func readSMCValue(key: String) -> Int16? {
        guard isConnected else { return nil }
        var inputStruct = SMCKeyData()
        var outputStruct = SMCKeyData()
        inputStruct.key = stringToUInt32(key)
        inputStruct.data8 = 5
        let inputSize = MemoryLayout<SMCKeyData>.size
        var outputSize = MemoryLayout<SMCKeyData>.size
        let result = IOConnectCallStructMethod(connection, 2, &inputStruct, inputSize, &outputStruct, &outputSize)
        guard result == kIOReturnSuccess else { return nil }
        return Int16(outputStruct.bytes.0) << 8 | Int16(outputStruct.bytes.1)
    }
}

// MARK: - Apple Silicon 温度（备选方案）

class AppleSiliconThermal {
    // 尝试从 IOHIDService 获取 Apple Silicon 温度
    static func getCPUTemperature() -> Double? {
        var iterator: io_iterator_t = 0

        // 尝试 AppleARMIODevice（M 系列芯片）
        let matchingDict = IOServiceMatching("AppleARMIODevice")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator) == kIOReturnSuccess else { return nil }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any] {
                // 在属性中查找温度
                if let temp = props["temperature"] as? Double, temp > 0 && temp < 150 {
                    IOObjectRelease(service)
                    return temp
                }
                if let temp = props["die-temperature"] as? Double, temp > 0 && temp < 150 {
                    IOObjectRelease(service)
                    return temp
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }

        // 尝试 thermal-sensors
        var iterator2: io_iterator_t = 0
        let matchingDict2 = IOServiceMatching("IOHIDEventService")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict2, &iterator2) == kIOReturnSuccess else { return nil }
        defer { IOObjectRelease(iterator2) }

        service = IOIteratorNext(iterator2)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any],
               let primaryUsagePage = props["PrimaryUsagePage"] as? Int,
               primaryUsagePage == 0xFF00 { // 厂商自定义
                if let temp = props["Temperature"] as? Double, temp > 0 && temp < 150 {
                    IOObjectRelease(service)
                    return temp
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator2)
        }

        return nil
    }
}

// MARK: - 亮度监控（缓存库句柄）

class BrightnessMonitor {
    typealias DisplayServicesGetBrightnessFunc = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32

    private var displayServicesHandle: UnsafeMutableRawPointer?
    private var getBrightnessFunc: DisplayServicesGetBrightnessFunc?

    init() {
        // 启动时只加载一次库
        displayServicesHandle = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_LAZY)
        if let handle = displayServicesHandle, let sym = dlsym(handle, "DisplayServicesGetBrightness") {
            getBrightnessFunc = unsafeBitCast(sym, to: DisplayServicesGetBrightnessFunc.self)
        }
    }

    deinit {
        if let handle = displayServicesHandle { dlclose(handle) }
    }

    func getBrightness() -> Float {
        guard let getFunc = getBrightnessFunc else { return -1 }
        var brightness: Float = 0
        let result = getFunc(CGMainDisplayID(), &brightness)
        return result == 0 && brightness >= 0 ? brightness : -1
    }
}

// MARK: - 网络接口

class NetworkInterface {
    var name: String
    var bytesIn: UInt64 = 0
    var bytesOut: UInt64 = 0
    var speedIn: Double = 0
    var speedOut: Double = 0
    var localIP: String = "—"

    init(name: String) {
        self.name = name
    }

    var displayName: String {
        // 将接口名映射为友好名称
        if name.hasPrefix("en") {
            if name == "en0" { return "Wi-Fi" }
            return "Ethernet (\(name))"
        }
        if name.hasPrefix("bridge") { return "Bridge" }
        if name.hasPrefix("utun") { return "VPN (\(name))" }
        if name.hasPrefix("awdl") { return "AirDrop" }
        if name.hasPrefix("llw") { return "Low Latency WLAN" }
        return name
    }
}

// MARK: - 指标

class Metrics {
    var cpu: Double = 0, cpuTemp: Double = 0, cpuCores: Int = 0, cpuModel: String = ""
    var cpuHistory: [Double] = []

    var mem: Double = 0, memUsed: UInt64 = 0, memTotal: UInt64 = 0
    var memActive: UInt64 = 0, memWired: UInt64 = 0, memCompressed: UInt64 = 0
    var swapUsed: UInt64 = 0, swapTotal: UInt64 = 0
    var memHistory: [Double] = []

    var gpu: Double = 0, gpuName: String = "", gpuTemp: Double = 0
    var gpuHistory: [Double] = []
    var displayRefreshRate: Int = 0

    // 网络 - 多接口支持
    var interfaces: [String: NetworkInterface] = [:]
    var sortedInterfaces: [String] = []
    var selectedInterfaceIndex: Int = 0

    // 当前选中接口统计（兼容旧版）
    var netIn: Double = 0, netOut: Double = 0
    var netTotalIn: UInt64 = 0, netTotalOut: UInt64 = 0
    var localIP: String = "—", externalIP: String = "Fetching..."
    var netHistory: [Double] = []

    var diskUsed: Double = 0, diskFree: UInt64 = 0, diskTotal: UInt64 = 0, diskName: String = "Macintosh HD"
    var ssdHealthPercent: Int = -1  // -1 表示不可用

    var battLevel: Double = 100, battCharging: Bool = false, battTimeRemaining: Int = -1, hasBatt: Bool = false
    var powerWatts: Double = -1  // -1 表示不可用

    var screenBrightness: Double = -1  // 0-100，-1 表示不可用
    var cpuFrequencyMHz: Int = -1  // -1 表示不可用

    var uptime: TimeInterval = 0
    var loadAvg: (Double, Double, Double) = (0, 0, 0)
    var fanSpeed: [Int] = []
    var processCount: Int = 0, kernelVersion: String = ""

    var prevTime: Date?, prevCPUTicks: [UInt64]?
}

// MARK: - 监控器

class Monitor {
    let metrics = Metrics()
    private var metalDevice: MTLDevice?
    private let smc = SMCService()
    private var externalIPFetched = false
    private let brightnessMonitor = BrightnessMonitor()

    // 分层更新计数器
    private var updateCounter: Int = 0

    // 带时间戳的缓存值
    private var lastSSDCheck: Date = .distantPast

    init() {
        metalDevice = MTLCreateSystemDefaultDevice()
        metrics.gpuName = metalDevice?.name ?? "Unknown GPU"
        metrics.cpuCores = ProcessInfo.processInfo.processorCount

        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpuModel = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpuModel, &size, nil, 0)
        metrics.cpuModel = String(cString: cpuModel)

        var kernSize: size_t = 0
        sysctlbyname("kern.osrelease", nil, &kernSize, nil, 0)
        var kernVersion = [CChar](repeating: 0, count: kernSize)
        sysctlbyname("kern.osrelease", &kernVersion, &kernSize, nil, 0)
        metrics.kernelVersion = String(cString: kernVersion)
    }

    // 快速更新 - 每秒调用（仅 CPU、网络）
    func updateFast() {
        updateCPU()
        updateNetwork()
        metrics.cpuHistory.append(metrics.cpu); if metrics.cpuHistory.count > 60 { metrics.cpuHistory.removeFirst() }
        metrics.netHistory.append(metrics.netIn + metrics.netOut); if metrics.netHistory.count > 60 { metrics.netHistory.removeFirst() }
    }

    // 中速更新 - 每 2 秒调用（内存、GPU）
    func updateMedium() {
        updateMemory()
        updateGPU()
        metrics.memHistory.append(metrics.mem); if metrics.memHistory.count > 60 { metrics.memHistory.removeFirst() }
        metrics.gpuHistory.append(metrics.gpu); if metrics.gpuHistory.count > 60 { metrics.gpuHistory.removeFirst() }
    }

    // 慢速更新 - 每 3 秒调用（温度、风扇）
    func updateSlow() {
        updateSensors()
    }

    // 很慢更新 - 每 10 秒调用（电池、系统信息）
    func updateVerySlow() {
        updateBattery()
        updateSystem()
        updateBrightness()
    }

    // 极慢更新 - 每 30 秒调用（磁盘、SSD 健康）
    func updateGlacial() {
        updateDisk()
        updateSSDHealthCached()
        if !externalIPFetched { externalIPFetched = true; fetchExternalIP() }
    }

    // 兼容旧版的单次更新函数
    func update() {
        updateCounter += 1

        // 快速更新 - 每次调用（1 秒）
        updateFast()

        // 中速更新 - 每 2 次调用（2 秒）
        if updateCounter % 2 == 0 {
            updateMedium()
        }

        // 慢速更新 - 每 5 次调用（3 秒）
        if updateCounter % 5 == 0 {
            updateSlow()
        }

        // 很慢更新 - 每 10 次调用（10 秒）
        if updateCounter % 10 == 0 {
            updateVerySlow()
        }

        // 极慢更新 - 每 30 次调用（30 秒）
        if updateCounter % 30 == 0 {
            updateGlacial()
        }

        // 首次运行 - 全量更新
        if updateCounter == 1 {
            updateMedium()
            updateSlow()
            updateVerySlow()
            updateGlacial()
        }

        // 重置计数器以防溢出
        if updateCounter >= 300 { updateCounter = 0 }
    }

    // 后台更新 - 面板隐藏时最小工作量
    func updateBackground() {
        updateCPU()
        updateMemory()
        updateNetwork()
        // 更新历史记录
        metrics.cpuHistory.append(metrics.cpu); if metrics.cpuHistory.count > 60 { metrics.cpuHistory.removeFirst() }
        metrics.memHistory.append(metrics.mem); if metrics.memHistory.count > 60 { metrics.memHistory.removeFirst() }
        metrics.netHistory.append(metrics.netIn + metrics.netOut); if metrics.netHistory.count > 60 { metrics.netHistory.removeFirst() }
    }

    private func updateCPU() {
        var info: processor_info_array_t?
        var msgCount: mach_msg_type_number_t = 0
        var cpuCount: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &info, &msgCount)
        guard result == KERN_SUCCESS, let cpuInfo = info else { return }
        defer { vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(msgCount) * vm_size_t(MemoryLayout<integer_t>.stride)) }

        var ticks: [UInt64] = [], totalUsage: Double = 0
        for i in 0..<Int(cpuCount) {
            let off = Int(CPU_STATE_MAX) * i
            let u = UInt64(cpuInfo[off + Int(CPU_STATE_USER)]), s = UInt64(cpuInfo[off + Int(CPU_STATE_SYSTEM)])
            let idle = UInt64(cpuInfo[off + Int(CPU_STATE_IDLE)]), n = UInt64(cpuInfo[off + Int(CPU_STATE_NICE)])
            ticks.append(contentsOf: [u, s, idle, n])
            if let prev = metrics.prevCPUTicks, prev.count > off + 3 {
                let du = u - prev[off], ds = s - prev[off + 1], di = idle - prev[off + 2], dn = n - prev[off + 3]
                let total = du + ds + di + dn
                if total > 0 { totalUsage += Double(du + ds + dn) / Double(total) * 100 }
            }
        }
        if metrics.prevCPUTicks != nil { metrics.cpu = totalUsage / Double(cpuCount) }
        metrics.prevCPUTicks = ticks
    }

    private func updateMemory() {
        metrics.memTotal = ProcessInfo.processInfo.physicalMemory
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) { p in
            p.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count) }
        }
        guard result == KERN_SUCCESS else { return }
        let page = UInt64(vm_kernel_page_size)
        metrics.memActive = UInt64(stats.active_count) * page
        metrics.memWired = UInt64(stats.wire_count) * page
        metrics.memCompressed = UInt64(stats.compressor_page_count) * page
        metrics.memUsed = metrics.memActive + metrics.memWired + metrics.memCompressed
        metrics.mem = Double(metrics.memUsed) / Double(metrics.memTotal) * 100
        var swapUsage = xsw_usage(); var swapSize = MemoryLayout<xsw_usage>.size
        if sysctlbyname("vm.swapusage", &swapUsage, &swapSize, nil, 0) == 0 {
            metrics.swapUsed = UInt64(swapUsage.xsu_used); metrics.swapTotal = UInt64(swapUsage.xsu_total)
        }
    }

    private func updateNetwork() {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return }
        defer { freeifaddrs(ifaddr) }

        let now = Date()
        var activeInterfaces: Set<String> = []
        var totalIn: UInt64 = 0, totalOut: UInt64 = 0
        var cur = first

        while true {
            let iface = cur.pointee
            let name = String(cString: iface.ifa_name)

            // 跳过回环接口
            if name == "lo0" {
                guard let next = iface.ifa_next else { break }
                cur = next
                continue
            }

            // 跟踪 AF_LINK 接口的字节数
            if iface.ifa_addr.pointee.sa_family == UInt8(AF_LINK),
               let data = iface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                let bytesIn = UInt64(data.pointee.ifi_ibytes)
                let bytesOut = UInt64(data.pointee.ifi_obytes)

                // 只跟踪有真实流量的接口
                if bytesIn > 0 || bytesOut > 0 {
                    activeInterfaces.insert(name)

                    // 获取或创建接口
                    if metrics.interfaces[name] == nil {
                        metrics.interfaces[name] = NetworkInterface(name: name)
                    }
                    let netIf = metrics.interfaces[name]!

                    // 基于上一轮字节数计算速度
                    if let pt = metrics.prevTime {
                        let dt = now.timeIntervalSince(pt)
                        if dt > 0 && netIf.bytesIn > 0 {
                            netIf.speedIn = Double(bytesIn > netIf.bytesIn ? bytesIn - netIf.bytesIn : 0) / dt
                            netIf.speedOut = Double(bytesOut > netIf.bytesOut ? bytesOut - netIf.bytesOut : 0) / dt
                        }
                    }

                    // 更新保存的字节数供下次计算
                    netIf.bytesIn = bytesIn
                    netIf.bytesOut = bytesOut

                    totalIn += bytesIn
                    totalOut += bytesOut
                }
            }

            // 获取 AF_INET 接口的 IP
            if iface.ifa_addr.pointee.sa_family == UInt8(AF_INET) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(iface.ifa_addr, socklen_t(iface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                let ip = String(cString: hostname)
                if !ip.isEmpty && !ip.hasPrefix("127.") {
                    if let netIf = metrics.interfaces[name] {
                        netIf.localIP = ip
                    }
                }
            }

            guard let next = iface.ifa_next else { break }
            cur = next
        }

        // 移除不再活跃的接口
        metrics.interfaces = metrics.interfaces.filter { activeInterfaces.contains($0.key) }

        // 更新已排序的接口列表
        metrics.sortedInterfaces = activeInterfaces.sorted { a, b in
            // 优先 en0（Wi‑Fi）和 en* 接口
            if a == "en0" { return true }
            if b == "en0" { return false }
            if a.hasPrefix("en") && !b.hasPrefix("en") { return true }
            if !a.hasPrefix("en") && b.hasPrefix("en") { return false }
            return a < b
        }

        // 确保选中索引有效
        if metrics.selectedInterfaceIndex >= metrics.sortedInterfaces.count {
            metrics.selectedInterfaceIndex = max(0, metrics.sortedInterfaces.count - 1)
        }

        // 从选中接口更新全局指标
        if !metrics.sortedInterfaces.isEmpty {
            let selectedName = metrics.sortedInterfaces[metrics.selectedInterfaceIndex]
            if let selected = metrics.interfaces[selectedName] {
                metrics.netIn = selected.speedIn
                metrics.netOut = selected.speedOut
                metrics.localIP = selected.localIP
            }
        }

        metrics.netTotalIn = totalIn
        metrics.netTotalOut = totalOut
        metrics.prevTime = now
    }

    private func fetchExternalIP() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let result: String
            if let url = URL(string: "https://api.ipify.org"),
               let ip = try? String(contentsOf: url, encoding: .utf8) {
                result = ip.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                result = "—"
            }
            DispatchQueue.main.async {
                self.metrics.externalIP = result
            }
        }
    }

    private func updateDisk() {
        let url = URL(fileURLWithPath: "/")
        guard let vals = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeNameKey]) else { return }
        metrics.diskTotal = UInt64(vals.volumeTotalCapacity ?? 0)
        metrics.diskFree = UInt64(vals.volumeAvailableCapacity ?? 0)
        metrics.diskName = vals.volumeName ?? "Macintosh HD"
        if metrics.diskTotal > 0 { metrics.diskUsed = Double(metrics.diskTotal - metrics.diskFree) / Double(metrics.diskTotal) * 100 }
    }

    private func updateBattery() {
        guard let snap = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let srcs = IOPSCopyPowerSourcesList(snap)?.takeRetainedValue() as? [CFTypeRef], !srcs.isEmpty else { metrics.hasBatt = false; return }
        for src in srcs {
            guard let info = IOPSGetPowerSourceDescription(snap, src)?.takeUnretainedValue() as? [String: Any],
                  info[kIOPSTypeKey as String] as? String == kIOPSInternalBatteryType as String else { continue }
            let cur = info[kIOPSCurrentCapacityKey as String] as? Int ?? 0, max = info[kIOPSMaxCapacityKey as String] as? Int ?? 100
            metrics.battLevel = max > 0 ? Double(cur) / Double(max) * 100 : 0
            metrics.battCharging = info[kIOPSIsChargingKey as String] as? Bool ?? false
            metrics.battTimeRemaining = info[kIOPSTimeToEmptyKey as String] as? Int ?? -1
            metrics.hasBatt = true; return
        }
    }

    private func updateSystem() {
        var bt = timeval(); var size = MemoryLayout<timeval>.size; var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        if sysctl(&mib, 2, &bt, &size, nil, 0) == 0 { metrics.uptime = Date().timeIntervalSince1970 - Double(bt.tv_sec) }
        var loadavg: [Double] = [0, 0, 0]; getloadavg(&loadavg, 3); metrics.loadAvg = (loadavg[0], loadavg[1], loadavg[2])
        var procSize: size_t = 0; sysctlbyname("kern.proc.all", nil, &procSize, nil, 0)
        metrics.processCount = procSize / MemoryLayout<kinfo_proc>.size
    }

    private func updateGPU() {
        let matchDict = IOServiceMatching("IOAccelerator"); var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess else { return }
        defer { IOObjectRelease(iterator) }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any],
               let perfStats = props["PerformanceStatistics"] as? [String: Any],
               let gpuUtil = perfStats["Device Utilization %"] as? Int { metrics.gpu = Double(gpuUtil) }
            IOObjectRelease(service); service = IOIteratorNext(iterator)
        }

        // 获取显示器刷新率
        if let mode = CGDisplayCopyDisplayMode(CGMainDisplayID()) {
            let refreshRate = mode.refreshRate
            // ProMotion 可变刷新率会返回 0，改查名义刷新率
            if refreshRate > 0 {
                metrics.displayRefreshRate = Int(refreshRate)
            } else {
                // 对 ProMotion 显示器，假定最高刷新率（通常 120Hz）
                metrics.displayRefreshRate = 120
            }
        }
    }

    private func updateSensors() {
        // 优先尝试 SMC（Intel 机型及部分 Apple Silicon）
        if let temp = smc.getCPUTemperature() {
            metrics.cpuTemp = temp
        } else if let temp = AppleSiliconThermal.getCPUTemperature() {
            // 回退到 Apple Silicon 温度读取
            metrics.cpuTemp = temp
        }

        if let temp = smc.getGPUTemperature() {
            metrics.gpuTemp = temp
        }

        metrics.fanSpeed = []
        for i in 0..<2 { if let rpm = smc.getFanSpeed(fan: i), rpm > 0 { metrics.fanSpeed.append(rpm) } }

        // 更新功耗（开销较小）
        updatePowerConsumption()

        // 更新 CPU 频率（若可用，sysctl 开销较小）
        updateCPUFrequency()

        // 注意：亮度与 SSD 健康改为更慢的独立定时器
    }

    private func updateBrightness() {
        // 使用缓存的亮度监控（避免 dlopen/dlclose 开销）
        let brightness = brightnessMonitor.getBrightness()
        if brightness >= 0 {
            metrics.screenBrightness = Double(brightness * 100)
            return
        }

        // 回退到 IODisplayGetFloatParameter（现在每 10 秒调用，频率更低）
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IODisplayConnect"), &iterator)
        if result == kIOReturnSuccess {
            defer { IOObjectRelease(iterator) }
            var service = IOIteratorNext(iterator)
            while service != 0 {
                var brightnessValue: Float = 0
                IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightnessValue)
                if brightnessValue > 0 {
                    metrics.screenBrightness = Double(brightnessValue * 100)
                    IOObjectRelease(service)
                    return
                }
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
        }

        metrics.screenBrightness = -1
    }

    private func updatePowerConsumption() {
        // 尝试从 IOKit 电源信息获取功耗
        guard let powerSourceInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let powerSources = IOPSCopyPowerSourcesList(powerSourceInfo)?.takeRetainedValue() as? [Any],
              let firstSource = powerSources.first,
              let description = IOPSGetPowerSourceDescription(powerSourceInfo, firstSource as CFTypeRef)?.takeUnretainedValue() as? [String: Any] else {
            return
        }

        // 检查电源信息并尝试从 SMC 获取电流
        if description[kIOPSCurrentCapacityKey] != nil {
            // 尝试从 SMC 获取电流（IPBR = 电池电流）
            if let amperage = smc.readSMCValue(key: "IPBR") {
                // 功率 = 电压 * 电流（近似）
                let voltage = 12.0 // MacBook 电池电压近似值
                metrics.powerWatts = abs(Double(amperage) / 1000.0 * voltage)
            }
        }
    }

    private func updateCPUFrequency() {
        // 在 Apple Silicon 上无法直接获取 CPU 频率
        // 在 Intel 上可尝试从 sysctl 获取
        var freq: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        if sysctlbyname("hw.cpufrequency", &freq, &size, nil, 0) == 0 {
            metrics.cpuFrequencyMHz = Int(freq / 1_000_000)
        } else {
            // 尝试获取标称频率
            if sysctlbyname("hw.cpufrequency_max", &freq, &size, nil, 0) == 0 {
                metrics.cpuFrequencyMHz = Int(freq / 1_000_000)
            }
        }
    }

    private func updateSSDHealthCached() {
        // 每 60 秒检查一次 - SSD 健康变化不频繁
        guard Date().timeIntervalSince(lastSSDCheck) > 60 else { return }
        lastSSDCheck = Date()

        updateSSDHealth()
    }

    private func updateSSDHealth() {
        // 尝试通过 IOKit SMART 数据获取 SSD 健康
        var iterator: io_iterator_t = 0
        let matchDict = IOServiceMatching("IONVMeController")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess else { return }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any] {
                // 查找磨损水平或剩余寿命
                if let smartData = props["SMART Data"] as? [String: Any],
                   let lifeRemaining = smartData["Life Remaining"] as? Int {
                    metrics.ssdHealthPercent = lifeRemaining
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }

        // 备选：通过 diskutil 读取 NVMe SMART 属性
        if metrics.ssdHealthPercent < 0 {
            // 采用更简单方式 - 检查 IOAHCIBlockStorageDevice
            var ahciIterator: io_iterator_t = 0
            let ahciMatch = IOServiceMatching("IOAHCIBlockStorageDevice")
            if IOServiceGetMatchingServices(kIOMainPortDefault, ahciMatch, &ahciIterator) == kIOReturnSuccess {
                defer { IOObjectRelease(ahciIterator) }
                var ahciService = IOIteratorNext(ahciIterator)
                while ahciService != 0 {
                    var props: Unmanaged<CFMutableDictionary>?
                    if IORegistryEntryCreateCFProperties(ahciService, &props, kCFAllocatorDefault, 0) == kIOReturnSuccess,
                       let properties = props?.takeRetainedValue() as? [String: Any],
                       let smartCapable = properties["SMART Capable"] as? Bool, smartCapable {
                        // 设备支持 SMART
                        if let smartStatus = properties["SMART Status"] as? String {
                            metrics.ssdHealthPercent = smartStatus == "Verified" ? 100 : 50
                        }
                    }
                    IOObjectRelease(ahciService)
                    ahciService = IOIteratorNext(ahciIterator)
                }
            }
        }
    }
}

// MARK: - 点击处理的卡片类型

enum CardType: String {
    case cpu, memory, gpu, network, disk, battery, fans, system

    func open() {
        switch self {
        case .cpu, .memory, .system:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
        case .gpu, .fans:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/System Information.app"))
        case .network:
            // macOS Sonoma+ 网络设置 - 尝试多个 URL scheme
            let urls = [
                "x-apple.systempreferences:com.apple.wifi-settings-extension",
                "x-apple.systempreferences:com.apple.Network-Settings.extension",
                "x-apple.systempreferences:com.apple.preference.network"
            ]
            for urlString in urls {
                if let url = URL(string: urlString), NSWorkspace.shared.open(url) { break }
            }
        case .disk:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Disk Utility.app"))
        case .battery:
            // macOS Sonoma+ 电池设置
            if let url = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

// MARK: - 内容视图

class ContentView: NSView {
    var metrics: Metrics?
    let pad: CGFloat = 16
    let gap: CGFloat = 8
    var cardRects: [CardType: NSRect] = [:]
    var hoveredCard: CardType? = nil
    var trackingArea: NSTrackingArea?

    // 网络接口导航
    var netPrevArrowRect: NSRect = .zero
    var netNextArrowRect: NSRect = .zero

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }

    override func mouseMoved(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        var newHovered: CardType? = nil
        for (card, rect) in cardRects {
            if rect.contains(loc) {
                newHovered = card
                break
            }
        }
        if newHovered != hoveredCard {
            hoveredCard = newHovered
            if hoveredCard != nil {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
            needsDisplay = true
        }
    }

    override func mouseExited(with event: NSEvent) {
        if hoveredCard != nil {
            hoveredCard = nil
            NSCursor.arrow.set()
            needsDisplay = true
        }
    }

    override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)

        // 先检测网络接口箭头
        if let m = metrics {
            if netPrevArrowRect.contains(loc) && m.selectedInterfaceIndex > 0 {
                m.selectedInterfaceIndex -= 1
                updateSelectedInterfaceMetrics()
                needsDisplay = true
                return
            }
            if netNextArrowRect.contains(loc) && m.selectedInterfaceIndex < m.sortedInterfaces.count - 1 {
                m.selectedInterfaceIndex += 1
                updateSelectedInterfaceMetrics()
                needsDisplay = true
                return
            }
        }

        for (card, rect) in cardRects {
            if rect.contains(loc) {
                card.open()
                return
            }
        }
    }

    private func updateSelectedInterfaceMetrics() {
        guard let m = metrics, !m.sortedInterfaces.isEmpty else { return }
        let selectedName = m.sortedInterfaces[m.selectedInterfaceIndex]
        if let selected = m.interfaces[selectedName] {
            m.netIn = selected.speedIn
            m.netOut = selected.speedOut
            m.localIP = selected.localIP
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let m = metrics else { return }

        // 清空卡片区域
        cardRects.removeAll()

        // 填充整个背景
        Theme.bg.setFill()
        NSRect(x: 0, y: 0, width: frame.width, height: frame.height).fill()

        let w = frame.width - pad * 2
        var y = frame.height - pad

        // 页眉
        y -= 24
        let shadow = NSShadow()
        shadow.shadowColor = Theme.accent.withAlphaComponent(0.5)
        shadow.shadowBlurRadius = 8
        "MiniStat".draw(at: NSPoint(x: pad, y: y), withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: Theme.text, .shadow: shadow])
        let up = formatUptime(m.uptime)
        up.draw(at: NSPoint(x: frame.width - pad - up.size(withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)]).width, y: y + 2), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: Theme.text2])
        y -= gap

        // CPU - 88px
        let cpuH: CGFloat = 88
        y -= cpuH
        let cpuRect = NSRect(x: pad, y: y, width: w, height: cpuH)
        cardRects[.cpu] = cpuRect
        drawCardGlow(x: pad, y: y, w: w, h: cpuH, color: Theme.cpu, intensity: m.cpu / 100, isHovered: hoveredCard == .cpu)
        let cpuColor = m.cpu > 90 ? Theme.danger : (m.cpu > 70 ? Theme.warning : Theme.cpu)
        String(format: "%.1f%%", m.cpu).draw(at: NSPoint(x: pad + 14, y: y + cpuH - 36), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .bold), .foregroundColor: cpuColor])
        L10n.cpu.draw(at: NSPoint(x: pad + 14, y: y + cpuH - 52), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        m.cpuModel.replacingOccurrences(of: "Apple ", with: "").draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        // 核心数与频率
        var coreInfo = "\(m.cpuCores) \(L10n.cores)"
        if m.cpuFrequencyMHz > 0 {
            let ghz = Double(m.cpuFrequencyMHz) / 1000.0
            coreInfo += String(format: " • %.1f GHz", ghz)
        }
        coreInfo.draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: Theme.text3])
        if m.cpuTemp > 0 {
            let tc = m.cpuTemp > 85 ? Theme.danger : (m.cpuTemp > 70 ? Theme.warning : Theme.temp)
            tc.withAlphaComponent(0.15).setFill()
            NSBezierPath(roundedRect: NSRect(x: pad + 115, y: y + cpuH - 36, width: 52, height: 24), xRadius: 6, yRadius: 6).fill()
            String(format: "%.0f°C", m.cpuTemp).draw(at: NSPoint(x: pad + 122, y: y + cpuH - 34), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold), .foregroundColor: tc])
        }
        drawSparkline(m.cpuHistory, x: pad + w - 115, y: y + 6, w: 105, h: cpuH - 12, color: Theme.cpu)
        y -= gap

        // 内存 - 88px
        let memH: CGFloat = 88
        y -= memH
        let memRect = NSRect(x: pad, y: y, width: w, height: memH)
        cardRects[.memory] = memRect
        drawCardGlow(x: pad, y: y, w: w, h: memH, color: Theme.mem, intensity: m.mem / 100, isHovered: hoveredCard == .memory)
        let memColor = m.mem > 90 ? Theme.danger : (m.mem > 75 ? Theme.warning : Theme.mem)
        String(format: "%.1f%%", m.mem).draw(at: NSPoint(x: pad + 14, y: y + memH - 36), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .bold), .foregroundColor: memColor])
        L10n.memory.draw(at: NSPoint(x: pad + 14, y: y + memH - 52), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        String(format: "%.1f / %.0f GB", Double(m.memUsed)/Double(Constants.bytesPerGB), Double(m.memTotal)/Double(Constants.bytesPerGB)).draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        String(format: "Act: %.1fG  Wire: %.1fG  Comp: %.1fG", Double(m.memActive)/Double(Constants.bytesPerGB), Double(m.memWired)/Double(Constants.bytesPerGB), Double(m.memCompressed)/Double(Constants.bytesPerGB)).draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 9, weight: .regular), .foregroundColor: Theme.text3])
        drawSparkline(m.memHistory, x: pad + w - 115, y: y + 6, w: 105, h: memH - 12, color: Theme.mem)
        y -= gap

        // GPU - 88px（含图表）
        let gpuH: CGFloat = 88
        y -= gpuH
        let gpuRect = NSRect(x: pad, y: y, width: w, height: gpuH)
        cardRects[.gpu] = gpuRect
        drawCardGlow(x: pad, y: y, w: w, h: gpuH, color: Theme.gpu, intensity: m.gpu / 100, isHovered: hoveredCard == .gpu)
        String(format: "%.0f%%", m.gpu).draw(at: NSPoint(x: pad + 14, y: y + gpuH - 36), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .bold), .foregroundColor: Theme.gpu])
        L10n.gpu.draw(at: NSPoint(x: pad + 14, y: y + gpuH - 52), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        m.gpuName.replacingOccurrences(of: "Apple ", with: "").draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        // 显示器刷新率
        if m.displayRefreshRate > 0 {
            "\(m.displayRefreshRate) Hz".draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        }
        if m.gpuTemp > 0 {
            let gt = m.gpuTemp > 85 ? Theme.danger : (m.gpuTemp > 70 ? Theme.warning : Theme.temp)
            gt.withAlphaComponent(0.15).setFill()
            NSBezierPath(roundedRect: NSRect(x: pad + 95, y: y + gpuH - 36, width: 52, height: 24), xRadius: 6, yRadius: 6).fill()
            String(format: "%.0f°C", m.gpuTemp).draw(at: NSPoint(x: pad + 102, y: y + gpuH - 34), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold), .foregroundColor: gt])
        }
        drawSparkline(m.gpuHistory, x: pad + w - 115, y: y + 6, w: 105, h: gpuH - 12, color: Theme.gpu)
        y -= gap

        // 网络 - 100px
        let netH: CGFloat = 100
        y -= netH
        let netRect = NSRect(x: pad, y: y, width: w, height: netH)
        cardRects[.network] = netRect
        drawCardGlow(x: pad, y: y, w: w, h: netH, color: Theme.net, intensity: min((m.netIn + m.netOut) / 10000000, 1.0), isHovered: hoveredCard == .network)

        // 接口选择器（多接口时）
        if m.sortedInterfaces.count > 1 {
            let interfaceName = m.interfaces[m.sortedInterfaces[m.selectedInterfaceIndex]]?.displayName ?? m.sortedInterfaces[m.selectedInterfaceIndex]

            // 左箭头
            let leftArrowX = pad + 60
            let arrowY = y + netH - 18
            netPrevArrowRect = NSRect(x: leftArrowX - 4, y: arrowY - 4, width: 18, height: 18)
            let leftColor = m.selectedInterfaceIndex > 0 ? Theme.net : Theme.text3
            "◀".draw(at: NSPoint(x: leftArrowX, y: arrowY), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: leftColor])

            // 接口名称
            interfaceName.draw(at: NSPoint(x: leftArrowX + 18, y: arrowY), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text])

            // 右箭头
            let nameWidth = interfaceName.size(withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium)]).width
            let rightArrowX = leftArrowX + 22 + nameWidth
            netNextArrowRect = NSRect(x: rightArrowX - 4, y: arrowY - 4, width: 18, height: 18)
            let rightColor = m.selectedInterfaceIndex < m.sortedInterfaces.count - 1 ? Theme.net : Theme.text3
            "▶".draw(at: NSPoint(x: rightArrowX, y: arrowY), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: rightColor])

            L10n.network.draw(at: NSPoint(x: pad + 14, y: y + netH - 18), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        } else {
            // 单接口 - 若可用，显示接口名
            let interfaceLabel: String
            if m.sortedInterfaces.isEmpty {
                interfaceLabel = L10n.network
            } else {
                let firstInterfaceName = m.sortedInterfaces[0]
                if let interface = m.interfaces[firstInterfaceName] {
                    interfaceLabel = "\(L10n.network) (\(interface.displayName))"
                } else {
                    interfaceLabel = "\(L10n.network) (\(firstInterfaceName))"
                }
            }
            interfaceLabel.draw(at: NSPoint(x: pad + 14, y: y + netH - 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            netPrevArrowRect = .zero
            netNextArrowRect = .zero
        }

        "↓".draw(at: NSPoint(x: pad + 14, y: y + 56), withAttributes: [.font: NSFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: Theme.net])
        formatSpeed(m.netIn).draw(at: NSPoint(x: pad + 34, y: y + 58), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), .foregroundColor: Theme.net])
        "↑".draw(at: NSPoint(x: pad + 14, y: y + 32), withAttributes: [.font: NSFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: Theme.netUp])
        formatSpeed(m.netOut).draw(at: NSPoint(x: pad + 34, y: y + 34), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), .foregroundColor: Theme.netUp])
        "\(L10n.session): ↓\(formatBytes(m.netTotalIn))  ↑\(formatBytes(m.netTotalOut))".draw(at: NSPoint(x: pad + 14, y: y + 8), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: Theme.text3])
        // 右侧 IP - 位于图表上方
        "\(L10n.localIP):".draw(at: NSPoint(x: pad + 175, y: y + netH - 30), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        m.localIP.draw(at: NSPoint(x: pad + 215, y: y + netH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: Theme.text2])
        "\(L10n.publicIP):".draw(at: NSPoint(x: pad + 175, y: y + netH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        m.externalIP.draw(at: NSPoint(x: pad + 215, y: y + netH - 48), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: Theme.text2])
        // 右下角图表
        drawSparkline(m.netHistory, x: pad + w - 115, y: y + 6, w: 105, h: 40, color: Theme.net)
        y -= gap

        // 磁盘 - 80px
        let diskH: CGFloat = 80
        y -= diskH
        let diskRect = NSRect(x: pad, y: y, width: w, height: diskH)
        cardRects[.disk] = diskRect
        drawCard(x: pad, y: y, w: w, h: diskH, isHovered: hoveredCard == .disk)
        let diskColor = m.diskUsed > 90 ? Theme.danger : (m.diskUsed > 75 ? Theme.warning : Theme.disk)
        // 顶部百分比
        String(format: "%.0f%%", m.diskUsed).draw(at: NSPoint(x: pad + 14, y: y + diskH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .bold), .foregroundColor: diskColor])
        // 百分比下方的“磁盘”标签
        L10n.disk.draw(at: NSPoint(x: pad + 14, y: y + diskH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        // SSD 健康徽标（若可用）
        if m.ssdHealthPercent >= 0 {
            let healthColor = m.ssdHealthPercent > 80 ? Theme.batt : (m.ssdHealthPercent > 50 ? Theme.warning : Theme.danger)
            healthColor.withAlphaComponent(0.15).setFill()
            NSBezierPath(roundedRect: NSRect(x: pad + 95, y: y + diskH - 36, width: 75, height: 24), xRadius: 6, yRadius: 6).fill()
            "\(L10n.ssdHealth): \(m.ssdHealthPercent)%".draw(at: NSPoint(x: pad + 100, y: y + diskH - 34), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: healthColor])
        }
        // GB 信息
        String(format: "%.0f GB \(L10n.freeOf) %.0f GB", Double(m.diskFree)/Double(Constants.bytesPerGB), Double(m.diskTotal)/Double(Constants.bytesPerGB)).draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        // 底部磁盘名称
        m.diskName.draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: Theme.text3])
        // 右侧进度条
        drawProgressBar(value: m.diskUsed / 100, x: pad + 185, y: y + 14, w: w - 200, h: 10, color: diskColor)
        y -= gap

        // 电池 - 80px
        let battH: CGFloat = 80
        y -= battH
        let battRect = NSRect(x: pad, y: y, width: w, height: battH)
        cardRects[.battery] = battRect
        drawCard(x: pad, y: y, w: w, h: battH, isHovered: hoveredCard == .battery)
        if m.hasBatt {
            let battColor = m.battCharging ? Theme.accent : (m.battLevel < 20 ? Theme.danger : (m.battLevel < 40 ? Theme.warning : Theme.batt))
            // 顶部百分比
            "\(Int(m.battLevel))%".draw(at: NSPoint(x: pad + 14, y: y + battH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .bold), .foregroundColor: battColor])
            // 百分比下方标签
            (m.battCharging ? L10n.charging : L10n.battery).draw(at: NSPoint(x: pad + 14, y: y + battH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            // 剩余时间或状态
            if m.battTimeRemaining > 0 && !m.battCharging {
                let h = m.battTimeRemaining / 60, mn = m.battTimeRemaining % 60
                (h > 0 ? "\(h)h \(mn)m \(L10n.remaining)" : "\(mn)m \(L10n.remaining)").draw(at: NSPoint(x: pad + 14, y: y + 18), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
            } else if m.battCharging {
                L10n.connectedToPower.draw(at: NSPoint(x: pad + 14, y: y + 18), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.accent])
            }
            drawProgressBar(value: m.battLevel / 100, x: pad + 14, y: y + 4, w: w - 30, h: 10, color: battColor)
        } else {
            "AC".draw(at: NSPoint(x: pad + 14, y: y + battH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .bold), .foregroundColor: Theme.batt])
            L10n.power.draw(at: NSPoint(x: pad + 14, y: y + battH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            L10n.connectedToAdapter.draw(at: NSPoint(x: pad + 14, y: y + 18), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.batt])
        }
        y -= gap

        // 风扇 - 48px（若可用）
        if !m.fanSpeed.isEmpty {
            let fanH: CGFloat = 48
            y -= fanH
            let fanRect = NSRect(x: pad, y: y, width: w, height: fanH)
            cardRects[.fans] = fanRect
            drawCard(x: pad, y: y, w: w, h: fanH, isHovered: hoveredCard == .fans)
            L10n.fans.draw(at: NSPoint(x: pad + 14, y: y + fanH - 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            for (i, rpm) in m.fanSpeed.enumerated() {
                "\(L10n.fan) \(i + 1): \(rpm) RPM".draw(at: NSPoint(x: pad + 14 + CGFloat(i) * 150, y: y + 8), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold), .foregroundColor: Theme.fan])
            }
            y -= gap
        }

        // 系统 - 88px（加高以容纳亮度/功耗）
        let sysH: CGFloat = 88
        y -= sysH
        let sysRect = NSRect(x: pad, y: y, width: w, height: sysH)
        cardRects[.system] = sysRect
        drawCard(x: pad, y: y, w: w, h: sysH, isHovered: hoveredCard == .system)
        L10n.system.draw(at: NSPoint(x: pad + 14, y: y + sysH - 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        String(format: "\(L10n.load): %.2f  %.2f  %.2f", m.loadAvg.0, m.loadAvg.1, m.loadAvg.2).draw(at: NSPoint(x: pad + 14, y: y + 50), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium), .foregroundColor: Theme.system])
        "\(L10n.processes): \(m.processCount)".draw(at: NSPoint(x: pad + 220, y: y + 50), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium), .foregroundColor: Theme.text2])
        if m.swapUsed > 0 {
            String(format: "\(L10n.swap): %.1f / %.1f GB", Double(m.swapUsed)/Double(Constants.bytesPerGB), Double(m.swapTotal)/Double(Constants.bytesPerGB)).draw(at: NSPoint(x: pad + 14, y: y + 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        } else {
            "\(L10n.swap): \(L10n.notInUse)".draw(at: NSPoint(x: pad + 14, y: y + 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text3])
        }
        "\(L10n.kernel): \(m.kernelVersion)".draw(at: NSPoint(x: pad + 220, y: y + 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text3])
        // 底行显示亮度与功耗
        var bottomInfo: [String] = []
        if m.screenBrightness >= 0 {
            bottomInfo.append("\(L10n.brightness): \(Int(m.screenBrightness))%")
        }
        if m.powerWatts > 0 {
            bottomInfo.append(String(format: "\(L10n.powerUsage): %.1fW", m.powerWatts))
        }
        if !bottomInfo.isEmpty {
            bottomInfo.joined(separator: "  •  ").draw(at: NSPoint(x: pad + 14, y: y + 8), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        }
    }

    func drawCard(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, isHovered: Bool = false) {
        let rect = NSRect(x: x, y: y, width: w, height: h)
        let path = NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12)

        // 绘制渐变填充
        if let gradient = NSGradient(starting: Theme.cardGradientTop, ending: Theme.cardGradientBottom) {
            gradient.draw(in: path, angle: 90)  // 90 度 = 从上到下
        }

        // 绘制悬停高亮
        if isHovered {
            let hoverColor = Theme.current == .dark
                ? NSColor.white.withAlphaComponent(0.06)
                : NSColor.black.withAlphaComponent(0.04)
            hoverColor.setFill()
            path.fill()
        }

        // 绘制边框
        Theme.cardBorder.setStroke()
        path.stroke()
    }

    func drawCardGlow(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor, intensity: Double, isHovered: Bool = false) {
        if intensity > 0.5 {
            color.withAlphaComponent((intensity - 0.5) * 0.25).setFill()
            NSBezierPath(roundedRect: NSRect(x: x - 2, y: y - 2, width: w + 4, height: h + 4), xRadius: 14, yRadius: 14).fill()
        }
        drawCard(x: x, y: y, w: w, h: h, isHovered: isHovered)
    }

    func drawProgressBar(value: Double, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor) {
        Theme.progressBg.setFill()
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: h/2, yRadius: h/2).fill()
        let fillW = w * CGFloat(min(max(value, 0), 1))
        if fillW > 0 { color.setFill(); NSBezierPath(roundedRect: NSRect(x: x, y: y, width: fillW, height: h), xRadius: h/2, yRadius: h/2).fill() }
    }

    func drawSparkline(_ values: [Double], x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor) {
        // 透明背景 - 仅细边框
        color.withAlphaComponent(0.1).setFill()
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 6, yRadius: 6).fill()
        guard values.count >= 2 else { return }
        // 确保 maxV 是正数且至少为 1，避免除零
        let maxV = max(values.max() ?? 1, 0.001)
        guard maxV > 0 else { return }
        var pts: [NSPoint] = []
        for (i, v) in values.enumerated() {
            pts.append(NSPoint(x: x + 4 + CGFloat(i) / CGFloat(values.count - 1) * (w - 8), y: y + 4 + min(max(v, 0) / maxV, 1) * (h - 8)))
        }
        let fill = NSBezierPath(); fill.move(to: NSPoint(x: pts[0].x, y: y + 4)); pts.forEach { fill.line(to: $0) }; fill.line(to: NSPoint(x: pts.last!.x, y: y + 4)); fill.close()
        NSGradient(colors: [color.withAlphaComponent(0.4), color.withAlphaComponent(0.05)])?.draw(in: fill, angle: 90)
        let line = NSBezierPath(); line.move(to: pts[0]); pts.dropFirst().forEach { line.line(to: $0) }
        color.withAlphaComponent(0.4).setStroke(); line.lineWidth = 2.5; line.stroke()
        color.setStroke(); line.lineWidth = 1.5; line.stroke()
        if let last = pts.last { color.setFill(); NSBezierPath(ovalIn: NSRect(x: last.x - 3, y: last.y - 3, width: 6, height: 6)).fill() }
    }

    func formatSpeed(_ bps: Double) -> String {
        if bps < 1024 { return String(format: "%.0f B/s", bps) }
        if bps < 1024 * 1024 { return String(format: "%.1f KB/s", bps / 1024) }
        return String(format: "%.2f MB/s", bps / (1024 * 1024))
    }

    func formatBytes(_ bytes: UInt64) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
        if bytes < 1024 * 1024 * 1024 { return String(format: "%.1f MB", Double(bytes) / (1024 * 1024)) }
        return String(format: "%.2f GB", Double(bytes) / (1024 * 1024 * 1024))
    }

    func formatUptime(_ s: TimeInterval) -> String {
        let d = Int(s) / 86400, h = (Int(s) % 86400) / 3600, m = (Int(s) % 3600) / 60
        if d > 0 { return "↑ \(d)d \(h)h \(m)m" }
        if h > 0 { return "↑ \(h)h \(m)m" }
        return "↑ \(m)m"
    }
}

// MARK: - 无边框面板

class BorderlessPanel: NSPanel {
    override var canBecomeKey: Bool { true }

    init(contentRect: NSRect) {
        super.init(contentRect: contentRect,
                   styleMask: [.nonactivatingPanel, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)

        isFloatingPanel = true
        level = .popUpMenu
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        acceptsMouseMovedEvents = true

        // 圆角处理
        if let contentView = contentView {
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 12
            contentView.layer?.masksToBounds = true
            contentView.layer?.backgroundColor = Theme.bg.cgColor
        }
    }
}

// MARK: - 应用代理

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    var statusItem: NSStatusItem!
    var panel: BorderlessPanel!
    var contentView: ContentView!
    var monitor = Monitor()
    var timer: Timer?
    var menu: NSMenu!
    var eventMonitor: Any?

    var isPanelVisible = false
    var backgroundUpdateCounter = 0

    func createMenuBarIcon() -> NSImage {
        // 优先使用系统符号，确保在菜单栏上清晰可见
        if let symbol = NSImage(systemSymbolName: "gauge", accessibilityDescription: "MiniStat") {
            symbol.isTemplate = true
            return symbol
        }
        // 系统符号不可用时使用自绘图标
        // 创建显示器图标（类似 Lucide 的“monitor”图标）
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()

            // 显示器屏幕（圆角矩形）
            let screenRect = NSRect(x: 2, y: 5, width: 14, height: 10)
            let screen = NSBezierPath(roundedRect: screenRect, xRadius: 1.5, yRadius: 1.5)
            screen.lineWidth = 1.5
            screen.stroke()

            // 支架颈部
            let neck = NSBezierPath()
            neck.move(to: NSPoint(x: 9, y: 5))
            neck.line(to: NSPoint(x: 9, y: 3))
            neck.lineWidth = 1.5
            neck.stroke()

            // 支架底座
            let base = NSBezierPath()
            base.move(to: NSPoint(x: 5, y: 3))
            base.line(to: NSPoint(x: 13, y: 3))
            base.lineWidth = 1.5
            base.lineCapStyle = .round
            base.stroke()

            return true
        }
        image.isTemplate = true  // 适配菜单栏颜色
        return image
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        // 显式设置为配件应用，确保菜单栏图标可显示
        NSApp.setActivationPolicy(.accessory)
        // 默认使用方形长度，标题为空时也能留出图标空间。
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.isVisible = true
        if let btn = statusItem.button {
            btn.image = createMenuBarIcon()
            btn.imagePosition = .imageOnly
            btn.imageScaling = .scaleProportionallyDown
            if btn.image == nil { btn.title = "DP" }
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
            btn.action = #selector(handleClick)
            btn.target = self
        }

        let hasFans = !monitor.metrics.fanSpeed.isEmpty
        let height: CGFloat = hasFans ? 780 : 724

        panel = BorderlessPanel(contentRect: NSRect(x: 0, y: 0, width: 380, height: height))

        contentView = ContentView(frame: NSRect(x: 0, y: 0, width: 380, height: height))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = Theme.bg.cgColor
        contentView.layer?.cornerRadius = 12
        panel.contentView?.addSubview(contentView)

        setupMenu()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.update() }
        timer?.tolerance = 0.05  // 允许系统灵活调度，降低能耗
        update()
        
        // 监听系统休眠/锁屏通知
        let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
        workspaceNotificationCenter.addObserver(self, selector: #selector(systemWillSleep), name: NSWorkspace.willSleepNotification, object: nil)
        workspaceNotificationCenter.addObserver(self, selector: #selector(systemDidWake), name: NSWorkspace.didWakeNotification, object: nil)
        workspaceNotificationCenter.addObserver(self, selector: #selector(sessionDidResignActive), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        workspaceNotificationCenter.addObserver(self, selector: #selector(sessionDidBecomeActive), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
    }

    func setupMenu() {
        menu = NSMenu()

        // 语言子菜单
        let languageItem = NSMenuItem(title: L10n.language, action: nil, keyEquivalent: "")
        let languageMenu = NSMenu()
        for lang in Language.allCases {
            let item = NSMenuItem(title: lang.displayName, action: #selector(changeLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = lang
            if lang == L10n.current { item.state = .on }
            languageMenu.addItem(item)
        }
        languageItem.submenu = languageMenu
        menu.addItem(languageItem)

        // 主题子菜单
        let themeItem = NSMenuItem(title: L10n.theme, action: nil, keyEquivalent: "")
        let themeMenu = NSMenu()
        for theme in AppTheme.allCases {
            let item = NSMenuItem(title: theme.displayName, action: #selector(changeTheme(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = theme
            if theme == Settings.shared.theme { item.state = .on }
            themeMenu.addItem(item)
        }
        themeItem.submenu = themeMenu
        menu.addItem(themeItem)

        menu.addItem(NSMenuItem.separator())

        // 关于
        let aboutItem = NSMenuItem(title: L10n.about, action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L10n.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    // MARK: - 系统休眠/锁屏处理
    
    private var wasUpdatingBeforeSleep = false
    
    @objc func systemWillSleep() {
        wasUpdatingBeforeSleep = timer?.isValid ?? false
        timer?.invalidate()
        timer = nil
        print("MiniStat: 系统即将休眠，暂停更新")
    }
    
    @objc func systemDidWake() {
        if wasUpdatingBeforeSleep {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.update() }
            timer?.tolerance = 0.05
            update()
            print("MiniStat: 系统唤醒，恢复更新")
        }
    }
    
    @objc func sessionDidResignActive() {
        // 用户锁屏或切换用户时暂停
        timer?.invalidate()
        timer = nil
        print("MiniStat: 会话失活（锁屏），暂停更新")
    }
    
    @objc func sessionDidBecomeActive() {
        // 用户解锁或切换回来时恢复
        if timer == nil || !(timer?.isValid ?? false) {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.update() }
            timer?.tolerance = 0.05
            update()
            print("MiniStat: 会话激活（解锁），恢复更新")
        }
    }

    @objc func changeLanguage(_ sender: NSMenuItem) {
        guard let lang = sender.representedObject as? Language else { return }
        L10n.current = lang
        // 用新语言重建菜单
        setupMenu()
        // 刷新面板
        contentView.needsDisplay = true
    }

    @objc func changeTheme(_ sender: NSMenuItem) {
        guard let theme = sender.representedObject as? AppTheme else { return }
        Settings.shared.theme = theme
        setupMenu()  // 重建菜单以更新勾选项
        contentView.needsDisplay = true
        panel.backgroundColor = Theme.bg  // 更新面板背景
        contentView.layer?.backgroundColor = Theme.bg.cgColor
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MiniStat"
        alert.informativeText = "A lightweight macOS menu bar app for real-time system monitoring.\n\n© 2026 tzdjack \n\nhttps://github.com/tzdjack/MiniStat"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Repository")

        // 尝试加载图标
        let iconPaths = [
            // 相对于可执行文件的路径（打包后的 .app）
            Bundle.main.resourcePath?.appending("/AppIcon.icns"),
            // 源代码目录（开发时）
            Bundle.main.bundlePath.appending("/Sources/AppIcon.icns"),
            // 当前工作目录
            FileManager.default.currentDirectoryPath.appending("/Sources/AppIcon.icns"),
            FileManager.default.currentDirectoryPath.appending("/AppIcon.icns"),
        ]

        for path in iconPaths {
            if let path = path,
               FileManager.default.fileExists(atPath: path),
               let image = NSImage(contentsOfFile: path) {
                alert.icon = image
                break
            }
        }

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://github.com/tzdjack/MiniStat") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func formatSpeedCompact(_ bps: Double) -> String {
        if bps < 1024 { return String(format: "%.0fB/s", bps) }
        if bps < 1024 * 1024 { return String(format: "%.1fKB/s", bps / 1024) }
        return String(format: "%.2fMB/s", bps / (1024 * 1024))
    }

    func updateMenuBarDisplay() {
        let m = monitor.metrics
        
        // 固定显示系统状态：网速 + CPU/MEM
        statusItem.length = NSStatusItem.variableLength
        statusItem.button?.image = nil
        statusItem.button?.imagePosition = .noImage
        
        // 格式化网速和系统指标
        let downStr = formatSpeedCompact(m.netIn)
        let upStr = formatSpeedCompact(m.netOut)
        // 百分比固定3字符宽度右对齐
        let cpuStr = String(format: "%3d", Int(m.cpu))
        let memStr = String(format: "%3d", Int(m.mem))
        
        // 计算字符宽度（等宽字体中所有字符都占1个宽度）
        func strWidth(_ s: String) -> Int {
            return s.count
        }
        
        // 固定第一列宽度为12（包含网速+箭头+空格），确保对齐
        let col1Width = 12
        let downPad = String(repeating: " ", count: max(0, col1Width - strWidth(downStr) - 1))  // -1为箭头
        let upPad = String(repeating: " ", count: max(0, col1Width - strWidth(upStr) - 1))
        
        // 布局：[空格填充+网速+箭头] [CPU/MEM]
        let line1 = "\(downPad)\(downStr)↓ C:\(cpuStr)%"
        let line2 = "\(upPad)\(upStr)↑ M:\(memStr)%"
        let menuText = "\(line1)\n\(line2)"
        
        let attributedText = NSMutableAttributedString(string: menuText)
        let fullRange = NSRange(location: 0, length: (menuText as NSString).length)
        
        // 使用8pt等宽字体
        let font = NSFont.monospacedSystemFont(ofSize: 8, weight: .regular)
        attributedText.addAttribute(.font, value: font, range: fullRange)
        
        // 设置行间距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        // 将文本渲染为图像以解决垂直居中问题
        let textSize = attributedText.size()
        let imageSize = NSSize(width: textSize.width, height: 22)  // 状态栏标准高度
        let image = NSImage(size: imageSize, flipped: false) { rect in
            // 计算垂直居中位置
            let yOffset = (rect.height - textSize.height) / 2 + 1  // +1微调
            attributedText.draw(at: NSPoint(x: 0, y: yOffset))
            return true
        }
        image.isTemplate = true
        
        statusItem.button?.image = image
        statusItem.button?.imagePosition = .imageOnly
    }

    func update() {
        if isPanelVisible {
            // 面板可见时进行全量更新
            monitor.update()
            contentView.metrics = monitor.metrics
            contentView.needsDisplay = true
        } else {
            // 后台更新 - 每秒一次
            monitor.updateBackground()
        }
        updateMenuBarDisplay()
    }

    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            // 若面板已打开先关闭
            if panel.isVisible {
                panel.orderOut(nil)
                isPanelVisible = false
                if let monitor = eventMonitor {
                    NSEvent.removeMonitor(monitor)
                    eventMonitor = nil
                }
            }
            statusItem.menu = menu; statusItem.button?.performClick(nil); statusItem.menu = nil
        } else { togglePanel() }
    }

    func togglePanel() {
        if panel.isVisible {
            panel.orderOut(nil)
            isPanelVisible = false
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
        } else if let btn = statusItem.button, let btnWindow = btn.window {
            let hasFans = !monitor.metrics.fanSpeed.isEmpty
            let height: CGFloat = hasFans ? 780 : 724

            // 将面板放在菜单栏按钮下方
            let btnRect = btn.convert(btn.bounds, to: nil)
            let screenRect = btnWindow.convertToScreen(btnRect)
            let x = screenRect.midX - 190  // 居中 380px 面板
            let y = screenRect.minY - height - 4  // 按钮下方 4px 间距

            panel.setFrame(NSRect(x: x, y: y, width: 380, height: height), display: true)
            contentView.frame = NSRect(x: 0, y: 0, width: 380, height: height)

            // 面板打开时立即全量更新
            monitor.update()
            contentView.metrics = monitor.metrics
            contentView.needsDisplay = true

            panel.orderFront(nil)
            panel.makeKey()  // 使面板成为 key 以接收鼠标事件
            isPanelVisible = true

            // 点击外部关闭
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.panel.orderOut(nil)
                self?.isPanelVisible = false
                if let monitor = self?.eventMonitor {
                    NSEvent.removeMonitor(monitor)
                    self?.eventMonitor = nil
                }
            }
        }
    }
}


