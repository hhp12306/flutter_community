import { FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos'

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
      // 第一个标签页：Flutter 页面
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
      .tabBar('Flutter')

      // 第二个标签页：示例页面
      TabContent() {
        Column() {
          Text('页面二')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('页面二')

      // 第三个标签页：示例页面
      TabContent() {
        Column() {
          Text('页面三')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .tabBar('页面三')

      // 第四个标签页：示例页面
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
      // 当切换标签页时更新当前索引
      this.currentTabIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}
