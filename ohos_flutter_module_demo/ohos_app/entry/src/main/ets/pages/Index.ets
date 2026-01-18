import { FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos'

@Entry
@Component
struct Index {

  private flutterEntry?: FlutterEntry;
  @State private flutterView: FlutterView | undefined = undefined;
  private isInitialized: boolean = false;

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
    RelativeContainer() {
      // 只有当 flutterView 初始化后才渲染 FlutterPage
      // 避免 FlutterPage 在未准备好时尝试访问 getDVModel
      if (this.flutterView) {
        FlutterPage({ viewId: this.flutterView.getId()})
      }
    }
  }
}
