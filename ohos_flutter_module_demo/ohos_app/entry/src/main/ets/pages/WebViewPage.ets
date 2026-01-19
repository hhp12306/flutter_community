import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

/**
 * WebView页面
 * 用于打开H5页面
 */
@Entry
@Component
struct WebViewPage {
  @State url: string = '';
  @State title: string = '详情';
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    // 从路由参数获取URL和标题
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.url = params['url'] || '';
      this.title = params['title'] || '详情';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
          .layoutWeight(1)

        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // WebView
      Web({
        src: this.url,
        controller: this.controller
      })
        .width('100%')
        .layoutWeight(1)
        .javaScriptAccess(true) // 启用JavaScript
        .onPageBegin((event) => {
          console.info('页面开始加载:', event?.url);
        })
        .onPageEnd((event) => {
          console.info('页面加载完成:', event?.url);
        })
        .onTitleReceive((event) => {
          if (event?.title) {
            this.title = event.title;
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
