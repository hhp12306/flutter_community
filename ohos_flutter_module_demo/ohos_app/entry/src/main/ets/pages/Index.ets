import { FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos'
import { router } from '@kit.ArkUI';

/**
 * 主页面
 * 包含底部导航栏：发现（Flutter）、商城、爱车、服务、我的
 */
@Entry
@Component
struct Index {

  private flutterEntry?: FlutterEntry;
  @State private flutterView: FlutterView | undefined = undefined;
  private isInitialized: boolean = false;
  // 当前选中的底部导航栏索引
  @State currentTabIndex: number = 0;

  aboutToAppear() {
    // 创建 FlutterEntry 实例，但不在 aboutToAppear 中调用 aboutToAppear()
    // 因为此时 ability 可能尚未完全附加，会导致 getAppComponent 返回 null
    this.flutterEntry = new FlutterEntry(getContext(this));
    
    // 检查是否有登录结果参数（从登录页返回）
    const params = router.getParams() as Record<string, Object>;
    if (params && params['loginResult'] !== undefined) {
      // 登录结果已通过DataPreferencesUtil保存，这里可以做一些UI更新
      console.info('登录结果:', params['loginResult']);
    }
  }

  aboutToDisappear() {
    this.flutterEntry?.aboutToDisappear();
  }

  onPageShow() {
    // 在 onPageShow 中初始化 FlutterEntry，此时组件已经完全附加
    // 可以安全地调用 aboutToAppear() 和 getFlutterView()
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
          // 只有当 flutterView 初始化后才渲染 FlutterPage
          // 避免 FlutterPage 在未准备好时尝试访问 getDVModel
          if (this.flutterView) {
            FlutterPage({ viewId: this.flutterView.getId()})
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
          Text('这里是商城页面')
            .fontSize(16)
            .margin({ top: 20 })
            .fontColor('#666666')
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
          Text('这里是爱车页面')
            .fontSize(16)
            .margin({ top: 20 })
            .fontColor('#666666')
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
          Text('这里是服务页面')
            .fontSize(16)
            .margin({ top: 20 })
            .fontColor('#666666')
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
          Text('这里是我的页面')
            .fontSize(16)
            .margin({ top: 20 })
            .fontColor('#666666')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('我的')
    }
    .onChange((index: number) => {
      // 当切换标签页时更新当前索引
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
