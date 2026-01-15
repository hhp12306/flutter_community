# 集成示例：处理原生 Tab 栏

## 快速集成步骤

### 1. 在原生项目中创建 FlutterContainerPage.ets

将 `FlutterContainerPage.ets` 文件复制到你的原生项目：
```
entry/src/main/ets/pages/FlutterContainerPage.ets
```

### 2. 在 main_pages.json 中添加路由

编辑 `entry/src/main/resources/base/profile/main_pages.json`：

```json
{
  "src": [
    "pages/Index",
    "pages/FlutterContainerPage"
  ]
}
```

### 3. 从原生页面跳转（传递 Tab 栏高度）

```typescript
import { router } from '@kit.ArkUI';

// 跳转到 Flutter 页面
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',
    tabBarHeight: '56' // 你的 Tab 栏高度（单位：vp）
  }
});
```

### 4. 调整 Tab 栏高度

如果默认的 56vp 不符合你的实际高度，有两种方式：

#### 方式 A：修改 FlutterContainerPage.ets 中的默认值

```typescript
// 修改这一行
private tabBarHeight: number = 56; // 改为你的实际高度，例如 48 或 60
```

#### 方式 B：跳转时传递（推荐）

```typescript
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',
    tabBarHeight: '48' // 根据实际高度传递
  }
});
```

## 完整示例

### 原生页面示例（带 Tab 栏）

```typescript
// Index.ets - 原生应用主页面
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  // 你的 Tab 栏高度
  private tabBarHeight: number = 56;

  build() {
    Column() {
      // 内容区域
      Column() {
        Text('原生应用内容')
          .fontSize(20)
        
        Button('打开 Flutter 发现页面')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/FlutterContainerPage',
              params: {
                route: '/discover',
                tabBarHeight: this.tabBarHeight.toString()
              }
            });
          })
      }
      .layoutWeight(1)
      .width('100%')
      
      // 底部 Tab 栏
      Row() {
        // 你的 Tab 栏内容
        Text('Tab 1')
        Text('Tab 2')
        Text('Tab 3')
      }
      .width('100%')
      .height(`${this.tabBarHeight}vp`)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
```

## 测试验证

1. **运行应用**
2. **点击跳转按钮**，打开 Flutter 页面
3. **检查**：
   - ✅ Flutter 页面内容是否完整显示
   - ✅ 底部 Tab 栏是否可见
   - ✅ 内容是否被 Tab 栏遮挡
   - ✅ 滚动时是否正常

## 常见问题

### Q1: Tab 栏还是被遮挡了

**解决**：
- 检查 `tabBarHeight` 值是否正确
- 确认单位是 `vp`（虚拟像素）
- 尝试增加高度值（例如从 56 改为 60）

### Q2: Flutter 页面底部有空白

**解决**：
- 检查 `tabBarHeight` 是否设置过大
- 确认原生 Tab 栏的实际高度
- 可以临时添加背景色查看实际布局区域

### Q3: 不同设备上高度不一致

**解决**：
- 使用 `vp` 单位（虚拟像素），会自动适配不同设备
- 如果仍有问题，可以动态获取 Tab 栏高度

## 动态获取 Tab 栏高度（高级）

如果你的 Tab 栏高度是动态的，可以这样获取：

```typescript
// 在原生应用中获取 Tab 栏组件的高度
// 假设你的 Tab 栏组件是 tabBarComponent
const actualHeight = this.tabBarComponent.getHeight();

// 跳转时传递实际高度
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',
    tabBarHeight: actualHeight.toString()
  }
});
```

## 总结

关键点：
1. ✅ 使用 `layoutWeight(1)` 让 Flutter 视图自动填充
2. ✅ 使用 `padding({ bottom })` 为 Tab 栏留出空间
3. ✅ 通过参数传递 Tab 栏高度，便于调整
4. ✅ 使用 `vp` 单位，自动适配不同设备

按照以上步骤操作即可解决 Tab 栏遮挡问题！
