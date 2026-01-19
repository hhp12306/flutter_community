# Android集成Flutter模块代码

## 一、依赖配置

### 1.1 settings.gradle

```gradle
include ':app'
setBinding(new Binding([gradle: this]))
evaluate(new File(
  settingsDir.parentFile,
  'my_flutter_module/.android/include_flutter.groovy'
))
```

### 1.2 app/build.gradle

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.example.host_app"
        minSdkVersion 21
        targetSdkVersion 33
    }
}

dependencies {
    implementation project(':flutter')
    // 其他依赖...
}
```

---

## 二、MainActivity实现

### 2.1 MainActivity.kt

```kotlin
package com.example.host_app

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.google.android.material.bottomnavigation.BottomNavigationView
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : AppCompatActivity() {
    
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    
    companion object {
        private const val FLUTTER_ENGINE_ID = "my_flutter_engine"
        private const val METHOD_CHANNEL_NAME = "com.example.my_flutter_module2/native"
        private const val EVENT_CHANNEL_NAME = "com.example.my_flutter_module2/native_events"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 初始化Flutter Engine
        initFlutterEngine()
        
        // 设置底部导航栏
        setupBottomNavigation()
    }
    
    /**
     * 初始化Flutter Engine
     */
    private fun initFlutterEngine() {
        // 获取或创建FlutterEngine
        flutterEngine = FlutterEngineCache.getInstance()
            .get(FLUTTER_ENGINE_ID) ?: createFlutterEngine()
        
        // 设置MethodChannel
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME
        )
        methodChannel.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
        
        // 设置EventChannel
        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL_NAME
        )
        
        // 预加载Flutter页面（可选，提升首次加载速度）
        flutterEngine.navigationChannel.setInitialRoute("/discover")
    }
    
    /**
     * 创建FlutterEngine
     */
    private fun createFlutterEngine(): FlutterEngine {
        val engine = FlutterEngine(this)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, engine)
        return engine
    }
    
    /**
     * 处理Flutter调用原生方法
     */
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // 检查登录状态
            "checkLoginStatus" -> {
                val isLoggedIn = checkLoginStatus()
                result.success(isLoggedIn)
            }
            
            // 跳转登录页
            "navigateToLogin" -> {
                navigateToLoginPage { loginSuccess ->
                    result.success(loginSuccess)
                }
            }
            
            // 获取用户信息
            "getUserInfo" -> {
                val userInfo = getUserInfo()
                result.success(userInfo)
            }
            
            // 登出
            "logout" -> {
                performLogout()
                result.success(null)
            }
            
            // 跳转原生页面
            "navigateToNativePage" -> {
                val pageName = call.argument<String>("pageName")
                val params = call.argument<Map<String, Any>>("params")
                navigateToNativePage(pageName, params)
                result.success(true)
            }
            
            // 打开原生WebView
            "openNativeWebView" -> {
                val url = call.argument<String>("url")
                val title = call.argument<String>("title")
                openNativeWebView(url, title)
                result.success(true)
            }
            
            // 获取共享数据
            "getSharedData" -> {
                val key = call.argument<String>("key")
                val value = getSharedData(key)
                result.success(value)
            }
            
            // 设置共享数据
            "setSharedData" -> {
                val key = call.argument<String>("key")
                val value = call.argument<Any>("value")
                setSharedData(key, value)
                result.success(true)
            }
            
            // 显示Toast
            "showToast" -> {
                val message = call.argument<String>("message")
                val duration = call.argument<String>("duration") ?: "short"
                showToast(message, duration)
                result.success(null)
            }
            
            // 显示Loading
            "showLoading" -> {
                val message = call.argument<String>("message")
                showLoading(message)
                result.success(null)
            }
            
            // 隐藏Loading
            "hideLoading" -> {
                hideLoading()
                result.success(null)
            }
            
            // 获取系统信息
            "getSystemInfo" -> {
                val systemInfo = getSystemInfo()
                result.success(systemInfo)
            }
            
            // 请求权限
            "requestPermission" -> {
                val permission = call.argument<String>("permission")
                requestPermission(permission) { granted ->
                    result.success(granted)
                }
            }
            
            else -> {
                result.notImplemented()
            }
        }
    }
    
    /**
     * 设置底部导航栏
     */
    private fun setupBottomNavigation() {
        val bottomNav = findViewById<BottomNavigationView>(R.id.bottom_navigation)
        
        bottomNav.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.nav_discover -> {
                    showFlutterFragment()
                    true
                }
                R.id.nav_mall -> {
                    navigateToMall()
                    true
                }
                R.id.nav_car -> {
                    navigateToCar()
                    true
                }
                R.id.nav_service -> {
                    navigateToService()
                    true
                }
                R.id.nav_mine -> {
                    navigateToMine()
                    true
                }
                else -> false
            }
        }
        
        // 默认显示发现页（Flutter页面）
        showFlutterFragment()
    }
    
    /**
     * 显示Flutter Fragment
     */
    private fun showFlutterFragment() {
        val flutterFragment = supportFragmentManager
            .findFragmentByTag("flutter_fragment") as? FlutterFragment
            ?: FlutterFragment
                .withCachedEngine(FLUTTER_ENGINE_ID)
                .shouldAttachEngineToActivity(false)
                .build()
        
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragment_container, flutterFragment, "flutter_fragment")
            .commit()
    }
    
    /**
     * 检查登录状态
     */
    private fun checkLoginStatus(): Boolean {
        // TODO: 实现实际的登录状态检查逻辑
        val prefs = getSharedPreferences("user_prefs", MODE_PRIVATE)
        return prefs.getBoolean("is_logged_in", false)
    }
    
    /**
     * 跳转登录页
     */
    private fun navigateToLoginPage(callback: (Boolean) -> Unit) {
        // TODO: 实现跳转登录页的逻辑
        // 例如：启动LoginActivity，在onActivityResult中处理登录结果
        val intent = Intent(this, LoginActivity::class.java)
        startActivityForResult(intent, REQUEST_CODE_LOGIN)
        
        // 注意：这里需要使用ActivityResultLauncher（AndroidX）或onActivityResult
        // 实际实现中，可以通过EventBus或其他方式回调结果
    }
    
    /**
     * 获取用户信息
     */
    private fun getUserInfo(): Map<String, Any>? {
        // TODO: 实现获取用户信息的逻辑
        val prefs = getSharedPreferences("user_prefs", MODE_PRIVATE)
        val isLoggedIn = prefs.getBoolean("is_logged_in", false)
        
        if (!isLoggedIn) {
            return null
        }
        
        return mapOf(
            "userId" to (prefs.getString("user_id", "") ?: ""),
            "userName" to (prefs.getString("user_name", "") ?: ""),
            "avatar" to (prefs.getString("avatar", "") ?: ""),
        )
    }
    
    /**
     * 执行登出
     */
    private fun performLogout() {
        // TODO: 实现登出逻辑
        val prefs = getSharedPreferences("user_prefs", MODE_PRIVATE)
        prefs.edit().clear().apply()
        
        // 通过EventChannel通知Flutter登录状态变化
        // eventChannel.setStreamHandler(...)
    }
    
    /**
     * 跳转原生页面
     */
    private fun navigateToNativePage(pageName: String?, params: Map<String, Any>?) {
        // TODO: 根据pageName跳转到对应的原生页面
        when (pageName) {
            "profile" -> {
                val intent = Intent(this, ProfileActivity::class.java)
                startActivity(intent)
            }
            "message" -> {
                val intent = Intent(this, MessageActivity::class.java)
                startActivity(intent)
            }
            // 其他页面...
        }
    }
    
    /**
     * 打开原生WebView
     */
    private fun openNativeWebView(url: String?, title: String?) {
        val intent = Intent(this, WebViewActivity::class.java).apply {
            putExtra("url", url)
            putExtra("title", title)
        }
        startActivity(intent)
    }
    
    /**
     * 获取共享数据
     */
    private fun getSharedData(key: String?): Any? {
        val prefs = getSharedPreferences("shared_data", MODE_PRIVATE)
        return prefs.getAll()[key]
    }
    
    /**
     * 设置共享数据
     */
    private fun setSharedData(key: String?, value: Any?) {
        val prefs = getSharedPreferences("shared_data", MODE_PRIVATE)
        val editor = prefs.edit()
        
        when (value) {
            is String -> editor.putString(key, value)
            is Int -> editor.putInt(key, value)
            is Boolean -> editor.putBoolean(key, value)
            is Float -> editor.putFloat(key, value)
            is Long -> editor.putLong(key, value)
        }
        
        editor.apply()
    }
    
    /**
     * 显示Toast
     */
    private fun showToast(message: String?, duration: String) {
        runOnUiThread {
            val toastDuration = if (duration == "long") {
                Toast.LENGTH_LONG
            } else {
                Toast.LENGTH_SHORT
            }
            Toast.makeText(this, message, toastDuration).show()
        }
    }
    
    /**
     * 显示Loading
     */
    private fun showLoading(message: String?) {
        // TODO: 实现显示Loading的逻辑（可以使用Dialog或ProgressBar）
    }
    
    /**
     * 隐藏Loading
     */
    private fun hideLoading() {
        // TODO: 实现隐藏Loading的逻辑
    }
    
    /**
     * 获取系统信息
     */
    private fun getSystemInfo(): Map<String, Any> {
        return mapOf(
            "platform" to "Android",
            "version" to android.os.Build.VERSION.SDK_INT,
            "model" to android.os.Build.MODEL,
        )
    }
    
    /**
     * 请求权限
     */
    private fun requestPermission(permission: String?, callback: (Boolean) -> Unit) {
        // TODO: 实现权限请求逻辑
        // 使用ActivityResultContracts.RequestPermission()
    }
    
    companion object {
        private const val REQUEST_CODE_LOGIN = 1001
    }
}
```

### 2.2 activity_main.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <!-- Flutter Fragment容器 -->
    <FrameLayout
        android:id="@+id/fragment_container"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toTopOf="@id/bottom_navigation" />

    <!-- 底部导航栏 -->
    <com.google.android.material.bottomnavigation.BottomNavigationView
        android:id="@+id/bottom_navigation"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="?android:attr/windowBackground"
        app:menu="@menu/bottom_navigation"
        app:layout_constraintBottom_toBottomOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

### 2.3 res/menu/bottom_navigation.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/nav_discover"
        android:icon="@drawable/ic_discover"
        android:title="发现" />
    <item
        android:id="@+id/nav_mall"
        android:icon="@drawable/ic_mall"
        android:title="商城" />
    <item
        android:id="@+id/nav_car"
        android:icon="@drawable/ic_car"
        android:title="爱车" />
    <item
        android:id="@+id/nav_service"
        android:icon="@drawable/ic_service"
        android:title="服务" />
    <item
        android:id="@+id/nav_mine"
        android:icon="@drawable/ic_mine"
        android:title="我的" />
</menu>
```

---

## 三、注意事项

1. **Flutter Engine缓存**：使用`FlutterEngineCache`缓存Engine，避免重复创建
2. **生命周期管理**：确保Flutter Engine的生命周期与Activity同步
3. **线程安全**：所有原生方法调用都应在主线程执行
4. **错误处理**：所有MethodChannel方法都应包含错误处理

---

## 四、测试

1. 确保Flutter模块已编译（`flutter build aar`）
2. 确保依赖已正确配置
3. 运行宿主APP，验证Flutter页面正常显示
4. 测试各种交互功能（登录、跳转等）
