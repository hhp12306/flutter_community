# 鸿蒙Next集成Flutter模块代码

## 一、依赖配置

### 1.1 oh-package.json5

```json5
{
  "dependencies": {
    "@ohos/flutter_ohos": "3.22.0-ohos",
    "@ohos/flutter_module": "file:../my_flutter_module/build/ohos/har/debug/flutter_module.har",
    "@ohos/flutter": "file:../my_flutter_module/build/ohos/har/debug/flutter.har"
  }
}
```

运行 `ohpm install` 安装依赖。

---

## 二、MainAbility实现

### 2.1 MainAbility.ets

```typescript
import { FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos'
import { MethodChannel, EventChannel } from '@ohos/flutter_ohos'

export default class MainAbility {
  private flutterEntry?: FlutterEntry;
  private methodChannel?: MethodChannel;
  private eventChannel?: EventChannel;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 创建FlutterEntry实例
    this.flutterEntry = new FlutterEntry(getContext(this));
    this.flutterEntry.aboutToAppear();
    
    // 获取FlutterView
    const flutterView = this.flutterEntry.getFlutterView();
    
    // 设置MethodChannel
    this.setupMethodChannel(flutterView);
    
    // 设置EventChannel
    this.setupEventChannel(flutterView);
  }

  /**
   * 设置MethodChannel
   */
  private setupMethodChannel(flutterView: FlutterView) {
    this.methodChannel = new MethodChannel(
      flutterView,
      'com.example.my_flutter_module2/native'
    );

    // 设置方法调用处理器
    this.methodChannel.setMethodCallHandler((call: MethodCall) => {
      return this.handleMethodCall(call);
    });
  }

  /**
   * 设置EventChannel
   */
  private setupEventChannel(flutterView: FlutterView) {
    this.eventChannel = new EventChannel(
      flutterView,
      'com.example.my_flutter_module2/native_events'
    );
    
    // 设置事件流处理器（可选）
    // this.eventChannel.setStreamHandler(...)
  }

  /**
   * 处理Flutter调用原生方法
   */
  private async handleMethodCall(call: MethodCall): Promise<any> {
    switch (call.method) {
      case 'checkLoginStatus':
        return this.checkLoginStatus();

      case 'navigateToLogin':
        return await this.navigateToLoginPage();

      case 'getUserInfo':
        return this.getUserInfo();

      case 'logout':
        this.performLogout();
        return null;

      case 'navigateToNativePage':
        const pageName = call.arguments?.pageName as string;
        const params = call.arguments?.params as Record<string, any>;
        this.navigateToNativePage(pageName, params);
        return true;

      case 'openNativeWebView':
        const url = call.arguments?.url as string;
        const title = call.arguments?.title as string;
        this.openNativeWebView(url, title);
        return true;

      case 'getSharedData':
        const key = call.arguments?.key as string;
        return this.getSharedData(key);

      case 'setSharedData':
        const dataKey = call.arguments?.key as string;
        const dataValue = call.arguments?.value;
        this.setSharedData(dataKey, dataValue);
        return true;

      case 'showToast':
        const message = call.arguments?.message as string;
        const duration = call.arguments?.duration as string || 'short';
        this.showToast(message, duration);
        return null;

      case 'showLoading':
        const loadingMessage = call.arguments?.message as string;
        this.showLoading(loadingMessage);
        return null;

      case 'hideLoading':
        this.hideLoading();
        return null;

      case 'getSystemInfo':
        return this.getSystemInfo();

      case 'requestPermission':
        const permission = call.arguments?.permission as string;
        return await this.requestPermission(permission);

      default:
        throw new Error(`Method ${call.method} not implemented`);
    }
  }

  /**
   * 检查登录状态
   */
  private checkLoginStatus(): boolean {
    // TODO: 实现实际的登录状态检查逻辑
    const preferences = dataPreferences.getPreferencesSync(getContext(this), 'user_prefs');
    return preferences.get('is_logged_in', false) as boolean;
  }

  /**
   * 跳转登录页
   */
  private async navigateToLoginPage(): Promise<boolean> {
    return new Promise((resolve) => {
      // TODO: 实现跳转登录页的逻辑
      const context = getContext(this);
      const want: Want = {
        bundleName: 'com.example.host_app',
        abilityName: 'LoginAbility',
      };

      context.startAbility(want).then(() => {
        // 监听登录结果（实际实现中需要通过EventChannel或其他方式获取结果）
        // 这里简化处理，假设登录成功
        resolve(true);
      }).catch((error) => {
        console.error('启动登录页面失败:', error);
        resolve(false);
      });
    });
  }

  /**
   * 获取用户信息
   */
  private getUserInfo(): Record<string, any> | null {
    const preferences = dataPreferences.getPreferencesSync(getContext(this), 'user_prefs');
    const isLoggedIn = preferences.get('is_logged_in', false) as boolean;

    if (!isLoggedIn) {
      return null;
    }

    return {
      userId: preferences.get('user_id', '') as string,
      userName: preferences.get('user_name', '') as string,
      avatar: preferences.get('avatar', '') as string,
    };
  }

  /**
   * 执行登出
   */
  private performLogout() {
    // TODO: 实现登出逻辑
    const preferences = dataPreferences.getPreferencesSync(getContext(this), 'user_prefs');
    preferences.delete('is_logged_in');
    preferences.delete('user_id');
    preferences.delete('user_name');
    preferences.delete('avatar');
    preferences.flushSync();

    // 通过EventChannel通知Flutter登录状态变化
    // this.eventChannel?.sendEvent({ type: 'logout' });
  }

  /**
   * 跳转原生页面
   */
  private navigateToNativePage(pageName: string, params?: Record<string, any>) {
    const context = getContext(this);
    const want: Want = {
      bundleName: 'com.example.host_app',
      abilityName: this.getAbilityNameByPageName(pageName),
      parameters: params || {},
    };

    context.startAbility(want).catch((error) => {
      console.error('启动页面失败:', error);
    });
  }

  /**
   * 根据页面名称获取Ability名称
   */
  private getAbilityNameByPageName(pageName: string): string {
    const pageMap: Record<string, string> = {
      'profile': 'ProfileAbility',
      'message': 'MessageAbility',
      // 其他页面映射...
    };
    return pageMap[pageName] || 'MainAbility';
  }

  /**
   * 打开原生WebView
   */
  private openNativeWebView(url: string, title?: string) {
    const context = getContext(this);
    const want: Want = {
      bundleName: 'com.example.host_app',
      abilityName: 'WebViewAbility',
      parameters: {
        url: url,
        title: title || '',
      },
    };

    context.startAbility(want).catch((error) => {
      console.error('启动WebView页面失败:', error);
    });
  }

  /**
   * 获取共享数据
   */
  private getSharedData(key: string): any {
    const preferences = dataPreferences.getPreferencesSync(getContext(this), 'shared_data');
    return preferences.get(key, null);
  }

  /**
   * 设置共享数据
   */
  private setSharedData(key: string, value: any) {
    const preferences = dataPreferences.getPreferencesSync(getContext(this), 'shared_data');
    preferences.put(key, value);
    preferences.flushSync();
  }

  /**
   * 显示Toast
   */
  private showToast(message: string, duration: string) {
    const context = getContext(this);
    const toastDuration = duration === 'long' ? 3500 : 2000;
    
    // TODO: 使用鸿蒙的Toast API
    // 注意：鸿蒙Next可能使用不同的Toast API，需要根据实际SDK版本调整
    console.log(`Toast: ${message} (${duration})`);
  }

  /**
   * 显示Loading
   */
  private showLoading(message?: string) {
    // TODO: 实现显示Loading的逻辑
    console.log(`Loading: ${message || '加载中...'}`);
  }

  /**
   * 隐藏Loading
   */
  private hideLoading() {
    // TODO: 实现隐藏Loading的逻辑
    console.log('Hide Loading');
  }

  /**
   * 获取系统信息
   */
  private getSystemInfo(): Record<string, any> {
    return {
      platform: 'HarmonyOS',
      version: 'HarmonyOS Next',
      model: 'HarmonyOS Device',
    };
  }

  /**
   * 请求权限
   */
  private async requestPermission(permission: string): Promise<boolean> {
    // TODO: 实现权限请求逻辑
    // 使用鸿蒙的权限API
    return new Promise((resolve) => {
      // 实际实现中需要使用 @ohos.abilityAccessCtrl 等API
      resolve(false);
    });
  }

  onDestroy() {
    this.flutterEntry?.aboutToDisappear();
  }
}
```

---

## 三、主页面实现

### 3.1 Index.ets（参考现有代码，增强功能）

```typescript
import { FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos'

@Entry
@Component
struct Index {
  private flutterEntry?: FlutterEntry;
  @State private flutterView: FlutterView | undefined = undefined;
  private isInitialized: boolean = false;
  @State currentTabIndex: number = 0;

  aboutToAppear() {
    // 创建 FlutterEntry 实例
    this.flutterEntry = new FlutterEntry(getContext(this));
  }

  aboutToDisappear() {
    this.flutterEntry?.aboutToDisappear();
  }

  onPageShow() {
    // 在 onPageShow 中初始化 FlutterEntry
    if (!this.isInitialized && this.flutterEntry) {
      this.flutterEntry.aboutToAppear();
      this.flutterView = this.flutterEntry.getFlutterView();
      this.isInitialized = true;
    }
    this.flutterEntry?.onPageShow();
  }

  onPageHide() {
    this.flutterEntry?.onPageHide();
  }

  build() {
    // 使用 Tabs 组件创建底部导航栏
    Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
      // 第一个标签页：Flutter 页面（发现）
      TabContent() {
        RelativeContainer() {
          if (this.flutterView) {
            FlutterPage({ viewId: this.flutterView.getId() })
          }
        }
        .width('100%')
        .height('100%')
      }
      .tabBar('发现')

      // 第二个标签页：商城
      TabContent() {
        Column() {
          Text('商城')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('商城')

      // 第三个标签页：爱车
      TabContent() {
        Column() {
          Text('爱车')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('爱车')

      // 第四个标签页：服务
      TabContent() {
        Column() {
          Text('服务')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('服务')

      // 第五个标签页：我的
      TabContent() {
        Column() {
          Text('我的')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('我的')
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
      
      // 当切换回发现Tab时，确保Flutter页面显示
      if (index === 0 && this.flutterView) {
        this.flutterEntry?.onPageShow();
      }
    })
    .width('100%')
    .height('100%')
  }
}
```

---

## 四、Module.json5配置

### 4.1 entry/src/main/module.json5

确保在`module.json5`中配置了必要的权限：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:permission_internet_reason",
        "usedScene": {
          "abilities": ["MainAbility"],
          "when": "inuse"
        }
      }
      // 其他权限...
    ],
    "abilities": [
      {
        "name": "MainAbility",
        "srcEntry": "./ets/entryability/MainAbility.ets",
        "description": "$string:MainAbility_desc",
        "icon": "$media:icon",
        "label": "$string:MainAbility_label",
        "type": "page",
        "launchType": "standard"
      }
      // 其他Ability...
    ]
  }
}
```

---

## 五、注意事项

1. **FlutterEntry生命周期**：确保在正确的生命周期方法中调用`aboutToAppear()`和`aboutToDisappear()`
2. **MethodChannel设置**：需要在FlutterView创建后才能设置MethodChannel
3. **数据持久化**：使用`@ohos.data.dataPreferences`进行数据存储
4. **权限请求**：根据实际需要请求相应权限
5. **线程安全**：确保所有方法调用都在主线程执行

---

## 六、HAR包生成

### 6.1 生成Flutter HAR包

```bash
cd my_flutter_module
flutter build ohos
```

生成的HAR包位于：
- `build/ohos/har/debug/flutter_module.har`
- `build/ohos/har/debug/flutter.har`

### 6.2 安装HAR包

将HAR包复制到宿主项目的`har`目录，或通过`oh-package.json5`引用。

---

## 七、测试

1. 确保Flutter模块已编译并生成HAR包
2. 确保依赖已正确配置（运行`ohpm install`）
3. 运行宿主APP，验证Flutter页面正常显示
4. 测试各种交互功能（登录、跳转等）

---

## 八、参考资料

- [Flutter for HarmonyOS](https://gitee.com/openharmony-sig/flutter_flutter)
- [HarmonyOS开发文档](https://developer.harmonyos.com/)
