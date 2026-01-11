# 发现功能模块 - 使用说明

## 项目概述

这是一个完整的Flutter模块项目，实现了类似比亚迪App五品牌社区的功能，命名为【发现】。

## 已实现的功能

### ✅ 1. 首页顶部
- ✅ 左侧：Tab栏（推荐、社区、俱乐部、智驾、活动、资讯、圈子、直播、口碑）
- ✅ 右侧：搜索图标、消息中心图标
- ✅ Tab过多时可滑动显示
- ✅ 支持手势左右滑动切换Tab
- ✅ 推荐、社区Tab不支持配置（固定显示）
- ✅ Tab文案后端返回，最多4个字
- ✅ 后台接口配置Tab是否显示及位置排序

### ✅ 2. 推荐页面
- ✅ Banner轮播图展示区（后台接口配置）
- ✅ 金刚区效果：一行5个图标，最多支持2行，可左右滑动多屏显示（后台接口配置）
- ✅ 功能组件区：展示组件类型、组件排序根据后台配置
- ✅ 精彩资讯，瀑布流效果：
  - 图片（视频封面）
  - 置顶（精选）+标题
  - 左侧：发布人头像、发布人、发布人下边显示车型Tag
  - 右侧：（点赞图标、点赞数量）或（收藏图标、收藏数量）

### ✅ 3. 社区页面
- ✅ 包括精选、最新、关注tab，默认进入精选tab
- ✅ 右下角悬浮显示发帖图标

### ✅ 4. 其他页面
- ✅ 俱乐部页面（框架）
- ✅ 智驾页面（Banner轮播图+图片占位功能区）
- ✅ 活动页面（框架）
- ✅ 资讯页面（框架）
- ✅ 圈子页面（框架）
- ✅ 直播页面（框架）
- ✅ 口碑页面（框架）

### ✅ 5. 发帖功能
- ✅ 发文字帖、视频帖、图片帖
- ✅ 支持图文混排
- ✅ 草稿箱功能

### ✅ 6. 视频播放页
- ✅ 支持视频缓存播放
- ✅ 上下手势滑动切换

### ✅ 7. 路由配置
- ✅ 配置完整的路由表
- ✅ 支持宿主App通过路由跳转Tab

### ✅ 8. 工具类
- ✅ 时间工具类：按规则格式化显示时间
- ✅ 数量工具类：按规则格式化显示数量

## 项目文件清单

### 核心文件（24个Dart文件）

#### 配置文件（2个）
- `lib/config/app_config.dart` - 应用配置
- `lib/config/app_routes.dart` - 路由配置

#### 数据模型（4个）
- `lib/models/tab_model.dart` - Tab配置模型
- `lib/models/banner_model.dart` - Banner模型
- `lib/models/diamond_model.dart` - 金刚区模型
- `lib/models/article_model.dart` - 文章/资讯模型

#### 服务层（1个）
- `lib/services/discover_service.dart` - 发现页面服务

#### 工具类（2个）
- `lib/utils/time_util.dart` - 时间工具类
- `lib/utils/count_util.dart` - 数量工具类

#### 视图层（15个）
- `lib/main.dart` - 主入口文件
- `lib/views/discover/discover_page.dart` - 发现主页
- `lib/views/discover/discover_provider.dart` - 状态管理
- `lib/views/discover/components/discover_app_bar.dart` - 顶部AppBar
- `lib/views/discover/components/discover_tab_bar.dart` - Tab栏组件
- `lib/views/discover/components/banner_carousel.dart` - Banner轮播组件
- `lib/views/discover/components/diamond_grid.dart` - 金刚区组件
- `lib/views/discover/components/article_list.dart` - 文章列表（瀑布流）
- `lib/views/discover/pages/recommend_page.dart` - 推荐页面
- `lib/views/discover/pages/community_page.dart` - 社区页面
- `lib/views/discover/pages/club_page.dart` - 俱乐部页面
- `lib/views/discover/pages/smart_drive_page.dart` - 智驾页面
- `lib/views/discover/pages/activity_page.dart` - 活动页面
- `lib/views/discover/pages/news_page.dart` - 资讯页面
- `lib/views/discover/pages/circle_page.dart` - 圈子页面
- `lib/views/discover/pages/live_page.dart` - 直播页面
- `lib/views/discover/pages/reputation_page.dart` - 口碑页面
- `lib/views/post/post_page.dart` - 发帖页面
- `lib/views/video/video_player_page.dart` - 视频播放页

## 安装和使用

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 配置API地址

编辑 `lib/config/app_config.dart`，设置正确的API基础URL：

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### 3. 运行项目

```bash
flutter run
```

### 4. 宿主App集成

宿主App可以通过路由跳转到发现模块的各个Tab：

```dart
// 使用GoRouter
context.go('/discover');
context.go('/discover/recommend');
context.go('/discover/community');
context.go('/discover?tabId=smart-drive');

// 或使用Navigator
Navigator.pushNamed(context, '/discover/recommend');
```

## 待完善功能

- [ ] 完善各个Tab页面的具体实现
- [ ] 实现搜索功能
- [ ] 实现消息中心
- [ ] 完善视频缓存功能
- [ ] 完善草稿箱的持久化存储
- [ ] 添加更多功能组件（热门话题、车型圈列表、专题合集等）
- [ ] 完善网络请求错误处理
- [ ] 添加加载状态和错误提示
- [ ] 完善图片和视频选择功能
- [ ] 添加下拉刷新和上拉加载更多

## 技术栈

- **Flutter**: UI框架
- **go_router**: 路由管理
- **provider**: 状态管理
- **dio**: 网络请求
- **cached_network_image**: 图片缓存加载
- **carousel_slider**: 轮播图
- **flutter_staggered_grid_view**: 瀑布流
- **video_player + chewie**: 视频播放
- **image_picker**: 图片/视频选择

## 注意事项

1. 所有依赖包需要在 `pubspec.yaml` 中配置
2. 需要确保Flutter SDK和依赖包版本兼容
3. 后端接口需要按照模型结构返回数据
4. 图片和视频资源需要配置正确的URL
5. 某些功能需要相应的权限配置（相机、相册等）

