# iOS集成Flutter模块代码

## 一、依赖配置

### 1.1 Podfile

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

target 'HostApp' do
  use_frameworks!

  # Flutter模块依赖
  flutter_application_path = '../my_flutter_module'
  load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
  
  install_all_flutter_pods(flutter_application_path)
  
  # 其他依赖...
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

运行 `pod install` 安装依赖。

---

## 二、AppDelegate实现

### 2.1 AppDelegate.swift

```swift
import UIKit
import Flutter
import FlutterPluginRegistrant

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var flutterEngine: FlutterEngine?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 初始化Flutter Engine
        initFlutterEngine()
        
        // 设置MethodChannel和EventChannel
        setupChannels()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /**
     * 初始化Flutter Engine
     */
    func initFlutterEngine() {
        // 创建Flutter Engine
        flutterEngine = FlutterEngine(name: "my_flutter_engine")
        flutterEngine?.run(withEntrypoint: nil)
        
        // 设置初始路由
        let navigationChannel = flutterEngine?.navigationChannel
        navigationChannel?.invokeMethod("setInitialRoute", arguments: "/discover")
        
        // 注册插件
        GeneratedPluginRegistrant.register(with: flutterEngine!)
    }
    
    /**
     * 设置MethodChannel和EventChannel
     */
    func setupChannels() {
        guard let binaryMessenger = flutterEngine?.binaryMessenger else {
            return
        }
        
        // MethodChannel
        methodChannel = FlutterMethodChannel(
            name: "com.example.my_flutter_module2/native",
            binaryMessenger: binaryMessenger
        )
        methodChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call: call, result: result)
        }
        
        // EventChannel
        eventChannel = FlutterEventChannel(
            name: "com.example.my_flutter_module2/native_events",
            binaryMessenger: binaryMessenger
        )
        // EventChannel的StreamHandler可以在这里设置
    }
    
    /**
     * 处理Flutter调用原生方法
     */
    func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkLoginStatus":
            let isLoggedIn = checkLoginStatus()
            result(isLoggedIn)
            
        case "navigateToLogin":
            navigateToLoginPage { loginSuccess in
                result(loginSuccess)
            }
            
        case "getUserInfo":
            let userInfo = getUserInfo()
            result(userInfo)
            
        case "logout":
            performLogout()
            result(nil)
            
        case "navigateToNativePage":
            if let args = call.arguments as? [String: Any],
               let pageName = args["pageName"] as? String {
                let params = args["params"] as? [String: Any]
                navigateToNativePage(pageName: pageName, params: params)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
            
        case "openNativeWebView":
            if let args = call.arguments as? [String: Any],
               let url = args["url"] as? String {
                let title = args["title"] as? String
                openNativeWebView(url: url, title: title)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
            
        case "getSharedData":
            if let args = call.arguments as? [String: Any],
               let key = args["key"] as? String {
                let value = getSharedData(key: key)
                result(value)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
            
        case "setSharedData":
            if let args = call.arguments as? [String: Any],
               let key = args["key"] as? String,
               let value = args["value"] {
                setSharedData(key: key, value: value)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
            
        case "showToast":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                let duration = args["duration"] as? String ?? "short"
                showToast(message: message, duration: duration)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
            
        case "showLoading":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                showLoading(message: message)
                result(nil)
            } else {
                result(nil)
            }
            
        case "hideLoading":
            hideLoading()
            result(nil)
            
        case "getSystemInfo":
            let systemInfo = getSystemInfo()
            result(systemInfo)
            
        case "requestPermission":
            if let args = call.arguments as? [String: Any],
               let permission = args["permission"] as? String {
                requestPermission(permission: permission) { granted in
                    result(granted)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /**
     * 检查登录状态
     */
    func checkLoginStatus() -> Bool {
        // TODO: 实现实际的登录状态检查逻辑
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "is_logged_in")
    }
    
    /**
     * 跳转登录页
     */
    func navigateToLoginPage(completion: @escaping (Bool) -> Void) {
        // TODO: 实现跳转登录页的逻辑
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.onLoginSuccess = { [weak self] in
                    completion(true)
                }
                loginVC.onLoginCancel = {
                    completion(false)
                }
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(loginVC, animated: true)
                }
            }
        }
    }
    
    /**
     * 获取用户信息
     */
    func getUserInfo() -> [String: Any]? {
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "is_logged_in")
        
        if !isLoggedIn {
            return nil
        }
        
        return [
            "userId": defaults.string(forKey: "user_id") ?? "",
            "userName": defaults.string(forKey: "user_name") ?? "",
            "avatar": defaults.string(forKey: "avatar") ?? "",
        ]
    }
    
    /**
     * 执行登出
     */
    func performLogout() {
        // TODO: 实现登出逻辑
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "is_logged_in")
        defaults.removeObject(forKey: "user_id")
        defaults.removeObject(forKey: "user_name")
        defaults.removeObject(forKey: "avatar")
        defaults.synchronize()
        
        // 通过EventChannel通知Flutter登录状态变化
        // eventChannel?.setStreamHandler(...)
    }
    
    /**
     * 跳转原生页面
     */
    func navigateToNativePage(pageName: String, params: [String: Any]?) {
        DispatchQueue.main.async {
            // TODO: 根据pageName跳转到对应的原生页面
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            switch pageName {
            case "profile":
                if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                    // 设置参数
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        rootVC.navigationController?.pushViewController(profileVC, animated: true)
                    }
                }
            case "message":
                if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        rootVC.navigationController?.pushViewController(messageVC, animated: true)
                    }
                }
            default:
                break
            }
        }
    }
    
    /**
     * 打开原生WebView
     */
    func openNativeWebView(url: String, title: String?) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let webVC = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
                webVC.url = url
                webVC.title = title
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.navigationController?.pushViewController(webVC, animated: true)
                }
            }
        }
    }
    
    /**
     * 获取共享数据
     */
    func getSharedData(key: String) -> Any? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key)
    }
    
    /**
     * 设置共享数据
     */
    func setSharedData(key: String, value: Any) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /**
     * 显示Toast
     */
    func showToast(message: String, duration: String) {
        DispatchQueue.main.async {
            // TODO: 实现Toast显示（可以使用第三方库如Toast-Swift）
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true) {
                    let delay = duration == "long" ? 3.0 : 2.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        alert.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    /**
     * 显示Loading
     */
    func showLoading(message: String?) {
        DispatchQueue.main.async {
            // TODO: 实现Loading显示（可以使用MBProgressHUD或其他库）
        }
    }
    
    /**
     * 隐藏Loading
     */
    func hideLoading() {
        DispatchQueue.main.async {
            // TODO: 实现Loading隐藏
        }
    }
    
    /**
     * 获取系统信息
     */
    func getSystemInfo() -> [String: Any] {
        return [
            "platform": "iOS",
            "version": UIDevice.current.systemVersion,
            "model": UIDevice.current.model,
        ]
    }
    
    /**
     * 请求权限
     */
    func requestPermission(permission: String, completion: @escaping (Bool) -> Void) {
        // TODO: 实现权限请求逻辑
        // 根据permission类型请求不同的权限（相机、位置、相册等）
        completion(false)
    }
}
```

---

## 三、ViewController实现

### 3.1 ViewController.swift

```swift
import UIKit
import Flutter

class ViewController: UIViewController {
    
    var flutterEngine: FlutterEngine?
    var flutterViewController: FlutterViewController?
    
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        showFlutterPage()
    }
    
    /**
     * 设置TabBar
     */
    func setupTabBar() {
        tabBar.delegate = self
        
        // 创建TabBar Items
        let discoverItem = UITabBarItem(title: "发现", image: UIImage(named: "ic_discover"), tag: 0)
        let mallItem = UITabBarItem(title: "商城", image: UIImage(named: "ic_mall"), tag: 1)
        let carItem = UITabBarItem(title: "爱车", image: UIImage(named: "ic_car"), tag: 2)
        let serviceItem = UITabBarItem(title: "服务", image: UIImage(named: "ic_service"), tag: 3)
        let mineItem = UITabBarItem(title: "我的", image: UIImage(named: "ic_mine"), tag: 4)
        
        tabBar.items = [discoverItem, mallItem, carItem, serviceItem, mineItem]
        tabBar.selectedItem = discoverItem
    }
    
    /**
     * 显示Flutter页面
     */
    func showFlutterPage() {
        // 获取Flutter Engine（从AppDelegate）
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            flutterEngine = appDelegate.flutterEngine
        }
        
        guard let engine = flutterEngine else {
            return
        }
        
        // 创建FlutterViewController
        flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        guard let flutterVC = flutterViewController else {
            return
        }
        
        // 添加到当前视图
        addChild(flutterVC)
        view.insertSubview(flutterVC.view, at: 0)
        flutterVC.view.frame = view.bounds
        flutterVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        flutterVC.didMove(toParent: self)
    }
}

// MARK: - UITabBarDelegate
extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            // 发现 - 显示Flutter页面
            showFlutterPage()
        case 1:
            // 商城 - 跳转到商城页面
            navigateToMall()
        case 2:
            // 爱车 - 跳转到爱车页面
            navigateToCar()
        case 3:
            // 服务 - 跳转到服务页面
            navigateToService()
        case 4:
            // 我的 - 跳转到我的页面
            navigateToMine()
        default:
            break
        }
    }
    
    func navigateToMall() {
        // TODO: 实现跳转商城页面
    }
    
    func navigateToCar() {
        // TODO: 实现跳转爱车页面
    }
    
    func navigateToService() {
        // TODO: 实现跳转服务页面
    }
    
    func navigateToMine() {
        // TODO: 实现跳转我的页面
    }
}
```

---

## 四、注意事项

1. **Flutter Engine管理**：在AppDelegate中创建并缓存FlutterEngine，避免重复创建
2. **线程安全**：所有原生方法调用都应在主线程执行（使用`DispatchQueue.main.async`）
3. **生命周期管理**：确保FlutterViewController的生命周期与ViewController同步
4. **错误处理**：所有MethodChannel方法都应包含错误处理

---

## 五、测试

1. 确保Flutter模块已编译
2. 运行 `pod install` 安装依赖
3. 运行宿主APP，验证Flutter页面正常显示
4. 测试各种交互功能（登录、跳转等）
