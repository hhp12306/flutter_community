// FlutterContainerPage.ets
// 用于原生鸿蒙项目的 Flutter 容器页面
// 已处理底部 Tab 栏高度问题

import flutterModule from '@ohos/flutter_module';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct FlutterContainerPage {
  @State route: string = '/discover';
  @State params: Record<string, string> = {};
  
  // Tab 栏高度（单位：vp），默认 56vp
  // 根据你的原生 Tab 栏实际高度调整
  private tabBarHeight: number = 56;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.route = params['route'] || '/discover';
      this.params = params;
      
      // 如果传递了 Tab 栏高度，使用传递的值
      if (params['tabBarHeight']) {
        this.tabBarHeight = parseInt(params['tabBarHeight']);
      }
    }
  }

  build() {
    Column() {
      // Flutter 视图
      // 使用 layoutWeight(1) 自动填充剩余空间
      // 底部通过 padding 留出 Tab 栏高度
      flutterModule.FlutterView({
        initialRoute: this.route,
        params: this.params
      })
      .layoutWeight(1) // 关键：使用权重，自动计算高度
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: `${this.tabBarHeight}vp` }) // 底部内边距，为 Tab 栏留出空间
    .justifyContent(FlexAlign.Start) // 顶部对齐
  }
}
