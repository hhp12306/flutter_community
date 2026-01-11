# 发现功能模块

这是一个类似比亚迪App五品牌社区功能的Flutter模块项目，命名为【发现】。

## 项目结构

```
lib/
├── main.dart                          # 主入口文件
├── config/                            # 配置文件
│   ├── app_config.dart               # 应用配置
│   └── app_routes.dart               # 路由配置
├── models/                            # 数据模型
│   ├── tab_model.dart                # Tab配置模型
│   ├── banner_model.dart             # Banner模型
│   ├── diamond_model.dart            # 金刚区模型
│   └── article_model.dart            # 文章/资讯模型
├── services/                          # 服务层
│   └── discover_service.dart         # 发现页面服务
├── utils/                             # 工具类
│   ├── time_util.dart                # 时间工具类
│   └── count_util.dart               # 数量工具类
└── views/                             # 视图层
    ├── discover/                      # 发现页面
    │   ├── discover_page.dart        # 发现主页
    │   ├── discover_provider.dart    # 状态管理
    │   ├── components/                # 组件
    │   │   ├── discover_app_bar.dart # 顶部AppBar
    │   │   ├── discover_tab_bar.dart # Tab栏组件
    │   │   ├── banner_carousel.dart  # Banner轮播组件
    │   │   ├── diamond_grid.dart     # 金刚区组件
    │   │   └── article_list.dart     # 文章列表组件（瀑布流）
    │   └── pages/                     # Tab页面
    │       ├── recommend_page.dart   # 推荐页面
    │       ├── community_page.dart   # 社区页面
    │       ├── club_page.dart        # 俱乐部页面
    │       ├── smart_drive_page.dart # 智驾页面
    │       ├── activity_page.dart    # 活动页面
    │       ├── news_page.dart        # 资讯页面
    │       ├── circle_page.dart      # 圈子页面
    │       ├── live_page.dart        # 直播页面
    │       └── reputation_page.dart  # 口碑页面
    ├── post/                          # 发帖功能
    │   └── post_page.dart            # 发帖页面
    └── video/                         # 视频播放
        └── video_player_page.dart    # 视频播放页
```

## 功能特性

### 1. 首页顶部
- 左侧：Tab栏（推荐、社区、俱乐部、智驾、活动、资讯、圈子、直播、口碑）
- 右侧：搜索图标、消息中心图标
- Tab过多时可滑动显示
- 支持手势左右滑动切换Tab
- 推荐、社区Tab不支持配置（固定显示）
- Tab文案后端返回，最多4个字

### 2. 推荐页面
- Banner轮播图展示区
- 金刚区效果：一行5个图标，最多支持2行，可左右滑动多屏显示
- 功能组件区：热门话题、车型圈列表、专题合集、专题
- 精彩资讯：瀑布流效果，展示图片/视频、标题、发布人信息、点赞/收藏数

### 3. 社区页面
- 包括精选、最新、关注tab，默认进入精选tab
- 右下角悬浮显示发帖图标

### 4. 发帖功能
- 支持发文字帖、视频帖、图片帖
- 支持图文混排
- 草稿箱功能

### 5. 视频播放页
- 支持视频缓存播放
- 上下手势滑动切换视频

### 6. 工具类
- **时间工具类**：按规则格式化显示时间
- **数量工具类**：按规则格式化显示数量

### 7. 路由配置
- 支持宿主App通过路由跳转Tab
- 路由表配置完整

## 安装依赖

在项目根目录运行：

```bash
flutter pub get
```

## 运行项目

```bash
flutter run
```

## 路由使用示例

### 宿主App跳转到发现页面

```dart
// 跳转到发现主页
Navigator.pushNamed(context, '/discover');

// 跳转到推荐Tab
Navigator.pushNamed(context, '/discover/recommend');

// 跳转到社区Tab
Navigator.pushNamed(context, '/discover/community');

// 跳转到智驾Tab
Navigator.pushNamed(context, '/discover/smart-drive');

// 使用GoRouter
context.go('/discover/recommend');
context.go('/discover?tabId=smart-drive');
```

## 注意事项

1. **依赖安装**：确保所有依赖包都已正确安装
2. **API配置**：在 `lib/config/app_config.dart` 中配置正确的API基础URL
3. **资源文件**：将图片和图标资源放到 `assets/images/` 和 `assets/icons/` 目录
4. **后端接口**：根据实际后端接口调整数据模型和服务层代码

## 待完善功能

- [ ] 完善各个Tab页面的具体实现
- [ ] 实现搜索功能
- [ ] 实现消息中心
- [ ] 完善视频缓存功能
- [ ] 完善草稿箱功能
- [ ] 添加更多功能组件（热门话题、车型圈列表、专题合集等）

